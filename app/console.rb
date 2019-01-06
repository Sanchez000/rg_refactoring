require_relative 'account'

class Console
  HELLO_MESSAGE = <<~HELLO_MESSAGE.freeze
    Hello, we are RubyG bank!
    - If you want to create account - press `create`
    - If you want to load account - press `load`
    - If you want to exit - press `exit`
  HELLO_MESSAGE

  def initialize
    @account = Account.new(self)
  end

  def hello
    puts HELLO_MESSAGE

    case gets.chomp
    when 'create' then @account.create
    when 'load' then @account.load
    else
      exit
    end
  end

  def main_menu
    puts main_menu_message

    loop do
      command = gets.chomp
      case command
      when 'SC' then @account.show_cards
      when 'CC' then @account.create_card # .card.create move to separete class Card
      when 'DC' then @account.destroy_card
      when 'PM' then @account.put_money
      when 'WM' then @account.withdraw_money
      when 'SM' then @account.send_money
      when 'DA' then @account.destroy && exit
      when 'exit' then exit
      else
        puts "Wrong command. Try again!\n"
      end
    end
  end

  def interviewer(personal_data)
    puts "Enter your #{personal_data}"
    gets.chomp
  end

  def first_ask_destroy_card(cards_array)
    puts 'If you want to delete:'
    listing_cards(cards_array)
    gets.chomp
  end

  def listing_cards(cards_array)
    cards_array.each_with_index do |card, index|
      puts "- #{card.card.number}, #{card.card.type}, press #{index + 1}"
    end
    puts "press `exit` to exit\n"
  end

  def menu_with_cards(cards, option)
    puts "Choose the card for #{option}ing:"
    listing_cards(cards)
  end

  def take_card_number
    puts 'Enter the recipient card:'
    gets.chomp
  end

  def are_you_sure?(what)
    puts "Are you sure you want to #{what} ?[y/n]" # delete #{card_number}?[y/n]
    gets.chomp == 'y'
  end

  def create_account?
    puts 'There is no active accounts, do you want to be the first?[y/n]'
    gets.chomp == 'y'
  end

  def no_accounts
    puts 'There is no account with given credentials'
  end

  def wrong_number
    puts "You entered wrong number!\n"
  end

  def no_enough_money
    puts 'There is no enough money on sender card'
  end

  def no_money_on_balance
    puts "You don't have enough money on card for such operation"
  end

  def higher_tax
    puts 'Your tax is higher than input amount'
  end

  def input_correct_amount
    puts 'You must input correct amount of money'
  end

  def no_cards
    puts "There is no active cards!\n"
  end

  def input_amount_to(operation)
    operation = 'put on your card' if operation == 'put'
    puts "Input the amount of money you want to #{operation}"
    gets.chomp&.to_i
  end

  def payment_result(amount, card, operation_type)
    case operation_type
    when 'put' then puts "Money #{amount} was put on #{card.number}.Balance: #{card.balance}.
      Tax: #{card.put_tax(amount)}"
    when 'withdraw' then puts "Money #{amount} withdrawed from #{card.number}$. Money left: #{card.balance}$.
      Tax: #{card.withdraw_tax(amount)}$"
    end
  end

  def credit_card_type
    puts <<~MENU_OF_CARD_TYPES
      You could create one of 3 card types
      - Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`
      - Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`
      - Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`
      - For exit - press `exit`
    MENU_OF_CARD_TYPES
    gets.chomp
    # not forget to add loop
  end

  private

  def main_menu_message
    <<~MAIN_MENU_MESSAGE
      \nWelcome, #{@account.current_account.name}
      If you want to:
      - show all cards - press SC
      - create card - press CC
      - destroy card - press DC
      - put money on card - press PM
      - withdraw money on card - press WM
      - send money to another card  - press SM
      - destroy account - press `DA`
      - exit from account - press `exit`
    MAIN_MENU_MESSAGE
  end
end
