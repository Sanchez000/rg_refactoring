module ConsoleForCards
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
    @current_account.cards.delete_if { |card| card.number == card_number }
    @current_account.save
  end
  
  def select_card(cards_array)
    cards_array.each_with_index do |card, index|
      puts "- #{card.number}, #{card.type}, press #{index + 1}"
    end
    output(:press_exit)
    answer = gets.chomp
    answer == 'exit' ? false : answer.to_i
  end
end
