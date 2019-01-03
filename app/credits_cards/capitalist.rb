module CreditCards
  class Capitalist < Base
    attr_accessor :balance
    attr_reader :number, :type

    def initialize
      @type = 'capitalist'
      @balance = 100.0
      @number = generate_card_number
    end

    def withdraw_tax(amount)
      amount * 0.04
    end

    def put_tax(*)
      10
    end

    def sender_tax(amount)
      amount * 0.1
    end
  end
end
