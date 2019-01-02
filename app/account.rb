require 'yaml'
require 'pry'

require_relative 'console'
require_relative 'credit_card'
require_relative 'validators/account_validator'

class Account
  attr_accessor :card
  attr_reader :current_account, :name, :password, :login, :age
  PATH_TO_DB = 'accounts.yml'.freeze

  def initialize(console)
    @errors = []
    @file_path = PATH_TO_DB
    @console = console
    @validator = Validators::Account.new
  end

  def show_cards
    if @current_account.card.any?
      @current_account.card.each do |card|
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

    @card = []
    new_accounts = accounts << self
    @current_account = self
    store_accounts(new_accounts)
    @console.main_menu
  end

  def create_card
    type = @console.credit_card_type
    new_card = CreditCard.new(type)
    cards = @current_account.card << new_card
    @current_account.card = cards
    save_account
    puts "Card with type - #{type} created"
  end

  def destroy_card
    loop do
      unless @current_account.card.any?
        puts "There is no active cards!\n"
        break
      end
      cards_array = @current_account.card
      answer = @console.first_ask_destroy_card(cards_array)
      break if answer == 'exit'

      answer = answer&.to_i
      unless answer.between?(0, cards_array.length)
        puts "You entered wrong number!\n"
      end
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

      if accounts.map { |a| { login: a.login, password: a.password } }.include?({ login: login, password: password })
        @current_account = accounts.select { |a| login == a.login }.first
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
    puts "There is no active cards!\n" unless @current_account.card.any?
    answer = @console.listing_cards(@current_account.card)

      loop do
        answer = gets.chomp
        break if answer == 'exit'

        answer = answer&.to_i
        unless answer.between?(0, @current_account.card.length)
          puts "You entered wrong number!\n"
          return
        end

          current_card = @current_account.card[answer - 1]

          loop do
            puts 'Input the amount of money you want to put on your card'
            a2 = gets.chomp
            unless a2&.to_i > 0
              puts 'You must input correct amount of money'
              return
            end

              if put_tax(current_card.card.type, current_card.card.balance, current_card.card.number, a2&.to_i.to_i) >= a2&.to_i.to_i
                puts 'Your tax is higher than input amount'
                return
              else
                new_money_amount = current_card[:balance] + a2&.to_i.to_i - put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)
                current_card[:balance] = new_money_amount
                @current_account.card[answer&.to_i.to_i - 1] = current_card
                save_account
                puts "Money #{a2&.to_i.to_i} was put on #{current_card[:number]}. Balance: #{current_card[:balance]}. Tax: #{put_tax(current_card[:type], current_card[:balance], current_card[:number], a2&.to_i.to_i)}"
                return
              end
          end
      end
  end

  private

  def store_accounts(new_accounts)
    File.open(@file_path, 'w') { |f| f.write new_accounts.to_yaml }
  end
end
