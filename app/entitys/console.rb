require_relative 'console_helpers/console_helper'
require_relative 'console_helpers/console_for_cards'
require_relative 'console_helpers/console_for_money'

class Console
  include ConsoleHelper
  include ConsoleForCards
  include ConsoleForMoney
  
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

  def destroy_account
    @current_account.destroy(@current_account.login) if are_you_sure?('destroy account')
  end
end
