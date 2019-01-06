require 'yaml'
require 'pry'

require_relative 'console'
require_relative 'credit_card'
require_relative 'credits_cards/usual'
require_relative 'validators/account_validator'

class Account
  attr_accessor :cards
  attr_reader :current_account, :name, :password, :login, :age
  PATH_TO_DB = 'accounts.yml'.freeze

  def initialize(console)
    @errors = []
    @file_path = PATH_TO_DB
    @console = console
    @validator = Validators::Account.new
  end

  def show_cards
    if @current_account.cards.any?
      @current_account.cards.each do |card|
        puts "- #{card.card.number}, #{card.card.type}"
      end
    else
      @console.no_cards
      puts @current_account
    end
  end

  def create
    set_account_data
    @cards = []
    new_accounts = accounts << self
    @current_account = self
    store_accounts(new_accounts)
    @console.main_menu
  end

  def set_account_data
    loop do
      @name = @console.interviewer('name')
      @age = @console.interviewer('age').to_i
      @login = @console.interviewer('login')
      @password = @console.interviewer('password')
      @validator.validate(self)
      break if @validator.valid?

      @validator.puts_errors
    end
  end

  def create_card
    type = @console.credit_card_type
    new_cards = @current_account.cards << CreditCard.new(type)
    @current_account.cards = new_cards
    save_account
  end

  def destroy_card
    cards_array = @current_account.cards
    return @console.no_cards unless cards_array.any?

    answer = @console.first_ask_destroy_card(cards_array)
    answer == 'exit' ? return : answer = answer&.to_i
    index = answer - 1
    return @console.wrong_number unless answer.between?(0, cards_array.length)

    return unless @console.are_you_sure?("delete #{cards_array[index].card.number}")

    cards_array.delete_at(index)
    save_account
  end

  def save_account
    new_accounts = accounts.each_with_object([]) do |account, array|
      account.login == @current_account.login ? array.push(@current_account) : array.push(account)
    end
    store_accounts(new_accounts)
  end

  def load
    loop do
      return create_the_first_account unless accounts.any?

      login = @console.interviewer('login')
      password = @console.interviewer('password')
      next @console.no_accounts unless find_account_by_login(login, password).any?

      @current_account = find_account_by_login(login, password).first
      break
    end
    @console.main_menu
  end

  def find_account_by_login(login, password)
    accounts.select { |account| login == account.login && password == account.password }
  end

  def create_the_first_account
    return create if @console.create_account?

    @console.hello
  end

  def destroy
    return unless @console.are_you_sure?('destroy account')

    index = accounts.find_index { |record| record.login == @current_account.login }
    temp_list = accounts
    temp_list.delete_at(index)
    store_accounts(temp_list)
  end

  def accounts
    return [] unless File.exist?(PATH_TO_DB)

    YAML.load_file(PATH_TO_DB)
  end

  def calculate_new_balance(card, amount, operation)
    case operation
    when 'withdraw' then card.balance - amount - card.withdraw_tax(amount)
    when 'send' then card.balance - amount - card.sender_tax(amount)
    when 'put' then card.balance + amount - card.put_tax(amount)
    end
  end

  def withdraw_money
    processing_transaction('withdraw')
  end

  def put_money
    processing_transaction('put')
  end

  def processing_transaction(operation)
    cards_array = @current_account.cards
    return @console.no_cards unless cards_array.any?

    @console.menu_with_cards(cards_array, operation)

    loop do
      answer = gets.chomp
      break if answer == 'exit'

      list_number = answer&.to_i
      return @console.wrong_number unless list_number.between?(0, cards_array.length)

      take_amount_to(operation, list_number, cards_array[list_number - 1])
    end
  end

  def take_amount_to(operation, card_index, current_card)
    loop do
      amount = @console.input_amount_to(operation)
      return @console.input_correct_amount if amount.negative?

      new_balance = calculate_new_balance(current_card.card, amount, operation)

      if operation == 'put'
        return @console.higher_tax if current_card.card.put_tax(amount) >= amount
      else
        return @console.no_money_on_balance unless new_balance.positive?
      end

      current_card.card.balance = new_balance
      @current_account.cards[card_index - 1] = current_card
      save_account
      return @console.payment_result(amount, current_card.card, operation)
    end
  end

  def send_money
    cards_array = @current_account.cards
    return @console.no_cards unless cards_array.any?

    @console.menu_with_cards(cards_array, 'sending')
    answer = gets.chomp
    answer == 'exit' ? exit : list_number = answer&.to_i
    return puts 'Choose correct card' unless list_number.between?(0, cards_array.length)

    pan = @console.take_card_number
    return puts 'Please, input correct number of card' unless pan.length == 16

    return puts "There is no card with number #{pan}\n" unless find_card_in_list(pan).any?

    # recipient_card = find_card_in_list(pan).first
    # sender_card = cards_array[list_number - 1]
    sending_loop(cards_array[list_number - 1], find_card_in_list(pan).first, list_number, pan)
  end

  def find_card_in_list(pan)
    all_cards = accounts.map(&:cards).flatten
    all_cards.select { |card| card.card.number == pan }
  end

  def sending_loop(sender_card, recipient_card, list_number, pan)
    loop do
      amount = @console.input_amount_to('withdraw')
      next @console.wrong_number if amount.negative?

      sender_balance = calculate_new_balance(sender_card.card, amount, 'send')
      next @console.no_money_on_balance if sender_balance.negative?

      recipient_balance = calculate_new_balance(recipient_card.card, amount, 'put')
      next @console.no_enough_money if recipient_card.card.put_tax(amount) >= amount

      sender_card.card.balance = sender_balance
      @current_account.cards[list_number - 1] = sender_card
      new_accounts = save_all_accounts(pan, recipient_balance)
      store_accounts(new_accounts)
      @console.payment_result(amount, sender_card.card, 'put')
      @console.payment_result(amount, recipient_card.card, 'put')
      break
    end
  end

  def save_all_accounts(pan, recipient_balance)
    accounts.each_with_object([]) do |account, array|
      array.push(@current_account) if account.login == @current_account.login

      if account.cards.map { |card| card.card.number }.include? pan
        recipient = account
        new_recipient_cards = recipient.cards.each_with_object([]) do |card, array_recipients|
          card.card.balance = recipient_balance if card.card.number == pan
          array_recipients.push(card)
        end

        recipient.cards = new_recipient_cards
        array.push(recipient)
      end
    end
  end

  private

  def store_accounts(new_accounts)
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
