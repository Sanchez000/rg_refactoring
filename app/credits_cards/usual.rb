module CreditCards # TODO: rename to CreditCardTypes maybe remove
  class Usual < Base # TODO: refactor to be equal
    attr_accessor :balance
    attr_reader :number, :type

    def initialize
      @type = 'usual'
      @balance = 50.0
      @number = generate_card_number
    end

    def withdraw_tax(amount)
      amount * 0.05
    end

    def put_tax(amount)
      amount * 0.2
    end

    def sender_tax
      20
    end
  end
end
