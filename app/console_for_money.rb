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
end