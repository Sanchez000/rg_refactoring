require 'yaml'
require 'pry'

class Transaction
  attr_accessor :errors, :card, :tax_amount, :amount

  def initialize(card)
    @card = card
  end

  def put_money(amount)
    @errors = []
    @amount = amount.to_i
    return @errors << 'You must input correct amount of money' unless @amount.positive?

    return @errors << 'Your tax is higher than input amount' if put_tax >= @amount

    card.balance = new_balance
  end

  def withdraw_money(amount)
    @errors = []
    @amount = amount.to_i
    return @errors << 'You must input correct amount of money' unless @amount.positive?

    return @errors << "You don't have enough money on card for such operation" unless money_left.positive?

    card.balance = money_left
  end

  private

  def new_balance
    card.balance + amount - @tax_amount
  end

  def money_left
    card.balance - amount - withdraw_tax
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
end
