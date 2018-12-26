require 'yaml'
require 'pry'

require_relative 'console'
require_relative 'credit_card'
require_relative 'validators/account_validator'

class Account
  attr_accessor :card
  attr_reader :current_account, :name, :password, :login, :age
  PATH_TO_DB = 'accounts.yml'

  def initialize(console)
    @errors = []
    @file_path = PATH_TO_DB
    @console = console
    @validator = Validators::Account.new
  end

  def show_cards
    #binding.pry
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
      @name = @console.interviewer('name')
      @age = @console.interviewer('age').to_i
      @login = @console.interviewer('login')
      @password = @console.interviewer('password')

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


  def destroy_card
    loop do
      if @current_account.card.any?
        cards_array = @current_account.card
        answer = @console.first_ask_destroy_card(cards_array)
        break if answer == 'exit'
        if answer&.to_i.between?(0, cards_array.length)
          confirm_delete = @console.confirm_delete_card(cards_array[answer&.to_i - 1].card.number)
          if confirm_delete == 'y'
            cards_array.delete_at(answer&.to_i - 1)
            save_account
            break
          else
            return
          end
        else
          puts "You entered wrong number!\n"
        end
      else
        puts "There is no active cards!\n"
        break
      end
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
      return create_the_first_account if !accounts.any?

      login = @console.interviewer('login')
      password = @console.interviewer('password')

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
    return create if gets.chomp == 'y'

    return console
    #else
    #
    #end
  end

  def destroy
    puts 'Are you sure you want to destroy account?[y/n]'
    a = gets.chomp
    if a == 'y'
      new_accounts = []
      accounts.each do |ac|
        if ac.login == @current_account.login
        else
          new_accounts.push(ac)
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
