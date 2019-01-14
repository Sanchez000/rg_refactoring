module ConsoleHelper
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
    gets.chomp == Console::YES
  end

  def want_create_account?
    output(:create_first_account)
    gets.chomp == Console::YES
  end

  def output(command)
    puts I18n.t(command)
  end
end