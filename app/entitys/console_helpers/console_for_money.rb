module ConsoleForMoney
  def withdraw_money
    puts I18n.t(:choose_card, operation: 'withdrawing')
    processing('withdrawing')
  end
  
  def put_money
    puts I18n.t(:choose_card, operation: 'putting')
    processing('putting')
  end
  
  def processing(operation)
    return output(:no_cards) unless @current_account.cards.any?

    list_number = select_card(@current_account.cards)
    return unless list_number

    return output(:wrong_number) unless list_number.between?(0, @current_account.cards.length)

    current_card = @current_account.cards[list_number - 1]
    initialize_transaction(current_card, operation)
  end
  
  def initialize_transaction(current_card, operation)
    transaction = Transaction.new(current_card)
    run_transaction(transaction, operation)
    @current_account.save
    puts I18n.t(:payment_result, amount: transaction.amount,
                                 number: current_card.number,
                                 balance: current_card.balance,
                                 tax_amount: transaction.tax_amount)
  end
  
  def run_transaction(transaction, operation)
    loop do
      if operation == 'putting'
        puts I18n.t(:input_amount, operation: 'put on your card')
        transaction.put_money(gets.chomp)
      else
        puts I18n.t(:input_amount, operation: 'withdraw')
        transaction.withdraw_money(gets.chomp)
      end
      break if transaction.errors.empty?

      transaction.errors.each { |error| puts error }
    end
  end
  
  def send_money
    puts I18n.t(:choose_card, operation: 'sending')
    
    return output(:no_cards) unless @current_account.cards.any?

    list_number = select_card(@current_account.cards)
    return unless list_number

    return output(:wrong_number) unless list_number.between?(0, @current_account.cards.length)

    current_card = @current_account.cards[list_number - 1]
    
    puts 'Enter the recipient card:'
    card_number = gets.chomp
    return puts 'Please, input correct number of card' if card_number.length != 16

    return puts "There is no card with number #{card_number}\n" unless find_card(card_number)
    
    recipient_card = find_card(card_number)
    take_and_put(current_card, recipient_card)
  end
  
  def take_and_put(sender_card, recipient_card)
      send_transaction = Transaction.new(sender_card)
      put_transaction = Transaction.new(recipient_card)
      loop do
        puts I18n.t(:input_amount, operation: 'withdraw')
        amount = gets.chomp
        send_transaction.send_money(amount)
        put_transaction.put_money(amount)
        break if send_transaction.errors.empty? && put_transaction.errors.empty?

        send_transaction.errors.each { |error| puts error }
        put_transaction.errors.each { |error| puts error }
      end
      @current_account.save
      puts I18n.t(:payment_result, amount: send_transaction.amount,
                                 number: sender_card.number,
                                 balance: sender_card.balance,
                                 tax_amount: send_transaction.tax_amount)
      puts I18n.t(:payment_result, amount: put_transaction.amount,
                                 number: recipient_card.number,
                                 balance: recipient_card.balance,
                                 tax_amount: put_transaction.tax_amount)
  end
  
  def find_card(card_number)
    all_cards = Account.accounts.map(&:cards).flatten
    all_cards.detect { |card| card.number == card_number }
  end
end