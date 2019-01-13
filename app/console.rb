require_relative 'account'
require_relative 'credit_cards'
require_relative 'transaction'

class Console
  attr_reader :account

  YES = 'y'.freeze
  START_COMMANDS = {
    create: 'create',
    load: 'load'
  }.freeze

  def initialize
    @errors = []
  end

  def hello
    output(:hello_message)
    case gets.chomp
    when START_COMMANDS[:create] then create_account
    when START_COMMANDS[:load] then load_account
    else
      exit
    end
  end

  def create_account
    account = Account.new
    loop do
      setting_parameters(account)
      break if account.valid?

      account.errors.each { |error| puts error }
    end
    account.save
    @current_account = account
    main_menu
  end

  def setting_parameters(account)
    account.name = interviewer('name')
    account.age = interviewer('age').to_i
    account.login = interviewer('login')
    account.password = interviewer('password')
  end

  def load_account
    loop do
      return create_the_first_account unless Account.accounts.any?

      login = interviewer('login')
      password = interviewer('password')
      @current_account = Account.find_by_credetials(login, password)
      output(:no_accounts) unless @current_account

      break if @current_account
    end
    main_menu
  end

  def create_the_first_account
    want_create_account? ? create_account : hello
  end

  def main_menu
    puts I18n.t(:main_menu_message, name: @current_account.name)

    loop do
      option = gets.chomp
      exit if option == 'exit'

      menu_select_option(option)
    end
  end

  def menu_select_option(option)
    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    case option
    when 'SC' then show_cards
    when 'CC' then create_card
    when 'DC' then destroy_card
    when 'PM' then put_money
    when 'WM' then withdraw_money
    when 'SM' then send_money
    when 'DA' then destroy_account && exit
    else
      output(:wrong_command)
    end
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity
  end

  def show_cards
    return output(:no_cards) unless @current_account.cards.any?

    expand_cards_list(@current_account.cards)
  end

  def create_card
    loop do
      card_type = choose_credit_card_type
      return puts I18n.t(:wrong_card_type) unless CreditCards::TYPES.key?(card_type)

      new_cards = @current_account.cards << CreditCards.new(card_type)
      @current_account.cards = new_cards
      @current_account.save
      break
    end
  end

  def select_card(cards_array)
    cards_array.each_with_index do |card, index|
      puts "- #{card.number}, #{card.type}, press #{index + 1}"
    end
    output(:press_exit)
    answer = gets.chomp
    answer == 'exit' ? false : answer.to_i
  end

  def withdraw_money
    output(:choose_card_withdrawing)
    return output(:no_cards) unless @current_account.cards.any?

    list_number = select_card(@current_account.cards)
    return unless list_number

    return output(:wrong_number) unless list_number.between?(0, @current_account.cards.length)

    current_card = @current_account.cards[list_number - 1]
    withdraw_amount(current_card)
  end

  def withdraw_amount(current_card)
    transaction = Transaction.new(current_card)
    run_withdraw(transaction)
    @current_account.save
    puts I18n.t(:payment_result, amount: transaction.amount,
                                 number: current_card.number,
                                 balance: current_card.balance,
                                 tax_amount: transaction.tax_amount)
  end

  def run_withdraw(transaction)
    loop do
      puts I18n.t(:input_amount, operation: 'withdraw')
      transaction.withdraw_money(gets.chomp)
      break if transaction.errors.empty?

      transaction.errors.each { |error| puts error }
    end
  end

  def put_money
    output(:choose_card)
    return output(:no_cards) unless @current_account.cards.any?

    list_number = select_card(@current_account.cards)
    return unless list_number

    return output(:wrong_number) unless list_number.between?(0, @current_account.cards.length)

    current_card = @current_account.cards[list_number - 1]
    put_amount(current_card)
  end

  def put_amount(current_card)
    transaction = Transaction.new(current_card)
    run_put(transaction)
    @current_account.save
    puts I18n.t(:payment_result, amount: transaction.amount,
                                 number: current_card.number,
                                 balance: current_card.balance,
                                 tax_amount: transaction.tax_amount)
  end

  def run_put(transaction)
    loop do
      puts I18n.t(:input_amount, operation: 'put on your card')
      transaction.put_money(gets.chomp)
      break if transaction.errors.empty?

      transaction.errors.each { |error| puts error }
    end
  end

  def destroy_card
    return output(:no_cards) unless @current_account.cards.any?

    confirm_delete
  end

  def confirm_delete
    loop do
      output(:want_delete?)
      list_number = select_card(@current_account.cards)
      return unless list_number

      return output(:wrong_number) unless list_number.between?(0, @current_account.cards.length)

      card_number = @current_account.cards[list_number - 1].number
      return unless are_you_sure?("delete #{card_number}")

      delete_card(card_number)
      break
    end
  end

  def delete_card(card_number)
    @current_account.cards.delete_if { |card| card.number = card_number }
    @current_account.save
  end

  def destroy_account
    @current_account.destroy(@current_account.login) if are_you_sure?('destroy account')
  end

  def interviewer(personal_data)
    puts "Enter your #{personal_data}"
    gets.chomp
  end

  def take_card_number
    output(:recipient_card)
    gets.chomp
  end

  def choose_credit_card_type
    output(:menu_of_card_types)
    gets.chomp
  end

  def expand_cards_list(cards_array)
    cards_array.each do |card|
      puts "- #{card.number}, #{card.type}"
    end
  end

  def are_you_sure?(what)
    puts "Are you sure you want to #{what} ?[y/n]"
    gets.chomp == YES
  end

  def want_create_account?
    output(:create_first_account)
    gets.chomp == YES
  end

  def output(command)
    puts I18n.t(command)
  end
end
