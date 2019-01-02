module CreditCards
  class Virtual < Base
    attr_accessor :balance
    attr_reader :number, :type

    def initialize
      @type = 'virtual'
      @balance = 150.0
      @number = generate_card_number
    end

    def withdraw_tax(amount)
      amount * 0.88
    end

    def put_tax
      1
    end

    def sender_tax
      1
    end
  end
end
