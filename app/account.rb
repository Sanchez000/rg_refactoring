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
      puts "There is no active cards!\n"
      puts @current_account
    end
  end

  def create
    loop do
      @name = @console.interviewer('name')
      @age = @console.interviewer('age').to_i
      @login = @console.interviewer('login')
      @password = @console.interviewer('password')

      @validator.validate(self)

      break if @validator.valid?

      @validator.puts_errors
    end

    @cards = []
    new_accounts = accounts << self
    @current_account = self
    store_accounts(new_accounts)
    @console.main_menu
  end

  def create_card
    type = @console.credit_card_type
    new_cards = @current_account.cards << CreditCard.new(type)
    @current_account.cards = new_cards
    save_account
  end

  def destroy_card
    loop do
      unless @current_account.cards.any?
        puts "There is no active cards!\n"
        break
      end
      cards_array = @current_account.cards
      answer = @console.first_ask_destroy_card(cards_array)
      break if answer == 'exit'

      answer = answer&.to_i
      @console.wrong_number unless answer.between?(0, cards_array.length)
      return unless @console.are_you_sure?("delete #{cards_array[answer - 1].card.number}")

      cards_array.delete_at(answer - 1)
      save_account
      break
    end
  end

  def save_account
    new_accounts = []
    accounts.each do |account|
      if account.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(account)
      end
    end
    store_accounts(new_accounts)
  end

  def load
    loop do
      return create_the_first_account unless accounts.any?

      login = @console.interviewer('login')
      password = @console.interviewer('password')
      if accounts.select { |a| login == a.login && password = a.password }.any?
        @current_account = accounts.select { |account| login == account.login }.first
        break
      else
        puts 'There is no account with given credentials'
        next
      end
    end
    @console.main_menu
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

  def put_money
    puts 'Choose the card for putting:'
    puts "There is no active cards!\n" unless @current_account.cards.any?
    @console.listing_cards(@current_account.cards)
    loop do
      answer = gets.chomp
      break if answer == 'exit'

      list_number = answer&.to_i
      return @console.wrong_number unless list_number.between?(0, @current_account.cards.length)

      get_amount(list_number, @current_account.cards[card_index - 1].card)
    end
  end

  def get_amount(card_index, current_card)
    loop do
      amount = @console.input_amount
      return puts 'You must input correct amount of money' if amount.negative?

      tax = current_card.put_tax(amount)
      return puts 'Your tax is higher than input amount' if tax >= amount

      current_card.balance = current_card.balance + amount - tax
      @current_account.cards[card_index - 1] = current_card
      save_account
      return @console.payment_result(amount, current_card)
    end
  end

  private

  def store_accounts(new_accounts)
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
