module ConsoleForMoney
  def withdraw_money
    output(:choose_card_withdrawing)
    return output(:no_cards) unless @current_account.cards.any?

    list_number = select_card(@current_account.cards)
    return unless list_number

    return output(:wrong_number) unless list_number.between?(0, @current_account.cards.length)

    current_card = @current_account.cards[list_number - 1]
    withdraw_amount(current_card)
  end
  
  def put_money
    output(:choose_card)
    return output(:no_cards) unless @current_account.cards.any?

    list_number = select_card(@current_account.cards)
    return unless list_number

    return output(:wrong_number) unless list_number.between?(0, @current_account.cards.length)

    current_card = @current_account.cards[list_number - 1]
    put_amount(current_card)
  end

  def withdraw_amount(current_card)
    transaction = Transaction.new(current_card)
    run_withdraw(transaction)
    @current_account.save
    puts I18n.t(:payment_result, amount: transaction.amount,
                                 number: current_card.number,
                                 balance: current_card.balance,
                                 tax_amount: transaction.tax_amount)
  end

  def put_amount(current_card)
    transaction = Transaction.new(current_card)
    run_put(transaction)
    @current_account.save
    puts I18n.t(:payment_result, amount: transaction.amount,
                                 number: current_card.number,
                                 balance: current_card.balance,
                                 tax_amount: transaction.tax_amount)
  end

  def run_put(transaction)
    loop do
      puts I18n.t(:input_amount, operation: 'put on your card')
      transaction.put_money(gets.chomp)
      break if transaction.errors.empty?

      transaction.errors.each { |error| puts error }
    end
  end
  
  def run_withdraw(transaction)
    loop do
      puts I18n.t(:input_amount, operation: 'withdraw')
      transaction.withdraw_money(gets.chomp)
      break if transaction.errors.empty?

      transaction.errors.each { |error| puts error }
    end
  end
end