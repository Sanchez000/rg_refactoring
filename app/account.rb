require 'yaml'
require 'pry'

require_relative 'console'
require_relative 'credit_card'
require_relative 'validators/account_validator'

class Account
  attr_accessor :card
  attr_reader :current_account, :name, :password, :login, :age
  PATH_TO_DB = 'accounts.yml'

  def initialize(console)#(file_path = PATH_TO_DB)
    @errors = []
    @file_path = PATH_TO_DB#file_path
    #@console = Console.new(self)
    #@console = Console.new
    @console = console
    @validator = Validators::Account.new
  end

  def show_cards
    #binding.pry # @current_account.card[0].card.balance/type/number
    if @current_account.card.any?
      @current_account.card.each do |card|
        #puts "- #{card[:number]}, #{card[:type]}" #
        puts "- #{card.card.number}, #{card.card.type}" #
      end
    else
      puts "There is no active cards!\n"
      puts @current_account
    end
  end

  def create
    loop do
      @name = @console.name_input
      @age = @console.age_input
      @login = @console.login_input
      @password = @console.password_input

      @validator.validate(self)

      break if @validator.valid?

      @validator.puts_errors
    end

    @card = [] # TODO: what is this? -> rename to @cards
    new_accounts = accounts << self
    @current_account = self
    store_accounts(new_accounts)
    @console.main_menu
  end

  def create_card
    # TODO: should we keep it here?
    type = @console.credit_card_type
    new_card = CreditCard.new(type)
    #binding.pry
    cards = @current_account.card << new_card
    @current_account.card = cards #important!!!
    new_accounts = []
    accounts.each do |account|
      if account.login == @current_account.login
        new_accounts.push(@current_account)
      else
        new_accounts.push(account)
      end
    end
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
    puts "Card with type - #{type} created"
  end

  def load
    loop do
      if !accounts.any?
        return create_the_first_account
      end

      puts 'Enter your login'
      login = gets.chomp
      puts 'Enter your password'
      password = gets.chomp

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        a = accounts.select { |a| login == a.login }.first
        @current_account = a
        break
      else
        puts 'There is no account with given credentials'
        next
      end
    end
    @console.main_menu
  end

  def create_the_first_account
    puts 'There is no active accounts, do you want to be the first?[y/n]'
    if gets.chomp == 'y'
      return create
    else
      return console
    end
  end

  def destroy
    puts 'Are you sure you want to destroy account?[y/n]'
    a = gets.chomp
    if a == 'y'
      new_accounts = []
      accounts.each do |account|
        if account.login == @current_account.login
        else
          new_accounts.push(account)
        end
      end
      store_accounts(new_accounts)
    end
  end

  def accounts
    return [] unless File.exists?(PATH_TO_DB)

    YAML.load_file(PATH_TO_DB)
  end

  private

  def store_accounts(new_accounts)
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
