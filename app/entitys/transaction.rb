class Transaction
  attr_accessor :errors, :card, :tax_amount, :amount

  def initialize(card)
    @card = card
  end

  def put_money(amount)
    @errors = []
    @amount = amount.to_i
    return @errors << I18n.t(:input_correct_amount) unless @amount.positive?

    return @errors << 'Your tax is higher than input amount' if put_tax >= @amount

    card.balance = new_balance
  end

  def withdraw_money(amount)
    @errors = []
    @amount = amount.to_i
    return @errors << I18n.t(:input_correct_amount) unless @amount.positive?

    return @errors << I18n.t(:no_money_on_balance) unless money_left.positive?

    card.balance = money_left
  end
  
  def send_money(amount)
    @errors = []
    @amount = amount.to_i
    return @errors << I18n.t(:input_correct_amount) unless @amount.positive?

    return @errors << I18n.t(:no_money_on_balance) unless money_left_after_sending.positive?

    card.balance = money_left_after_sending
  end

  private

  def new_balance
    card.balance + amount - put_tax# @tax_amount
  end

  def money_left
    card.balance - amount - withdraw_tax
  end
  
  def money_left_after_sending
    card.balance - amount - sender_tax
  end

  def put_tax
    taxes = {
      'usual' => amount * 0.02,
      'capitalist' => 10,
      'virtual' => 1
    }
    @tax_amount = taxes.key?(card.type) ? taxes[card.type] : 0
  end

  def withdraw_tax
    taxes = {
      'usual' => amount * 0.05,
      'capitalist' => amount * 0.04,
      'virtual' => amount * 0.88
    }
    @tax_amount = taxes.key?(card.type) ? taxes[card.type] : 0
  end
  
  def sender_tax
    taxes = {
      'usual' => 20,
      'capitalist' => amount * 0.1,
      'virtual' => 1
    }
    @tax_amount = taxes.key?(card.type) ? taxes[card.type] : 0
  end
end
