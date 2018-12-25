require_relative 'account'

class Console
  HELLO_MESSAGE = <<~HELLO_MESSAGE.freeze
    Hello, we are RubyG bank!
    - If you want to create account - press `create`
    - If you want to load account - press `load`
    - If you want to exit - press `exit`
  HELLO_MESSAGE

  def initialize #(account)
    @account = Account.new(self) # account
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
      when 'CC' then @account.create_card#.card.create move to separete class Card
      when 'DC' then @account.card.destroy
      when 'PM' then @account.card.put_money
      when 'WM' then @account.card.withdraw_money
      when 'SM' then @account.card.send_money
      when 'DA' then @account.destroy && exit
      when 'exit' then exit
      else
        puts "Wrong command. Try again!\n"
      end
    end
  end

  def name_input
    puts 'Enter your name'
    read_from_console
  end

  def age_input
    puts 'Enter your age'
    read_from_console.to_i
  end

  def login_input
    puts 'Enter your login'
    read_from_console
  end

  def password_input
    puts 'Enter your password'
    read_from_console
  end

  def credit_card_type
    puts <<~MENU_OF_CARD_TYPES
      You could create one of 3 card types
    - Usual card. 2% tax on card INCOME. 20$ tax on SENDING money from this card. 5% tax on WITHDRAWING money. For creation this card - press `usual`
    - Capitalist card. 10$ tax on card INCOME. 10% tax on SENDING money from this card. 4$ tax on WITHDRAWING money. For creation this card - press `capitalist`
    - Virtual card. 1$ tax on card INCOME. 1$ tax on SENDING money from this card. 12% tax on WITHDRAWING money. For creation this card - press `virtual`
    - For exit - press `exit`
    MENU_OF_CARD_TYPES
    read_from_console
    # not forget to add loop
  end

  private

  def read_from_console
    gets.chomp
  end

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
