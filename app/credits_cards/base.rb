module CreditCards
#class CreditCards::Base
class Base
  CARD_NUMBER_LENGTH = 16.freeze
  RANDOM_RANGE = 10.freeze
  def withdraw_tax
    raise NotImplementedError
  end

  def put_tax
    raise NotImplementedError
  end

  def sender_tax
    raise NotImplementedError
  end

  private

  def generate_card_number
    Array.new(CARD_NUMBER_LENGTH) { rand(RANDOM_RANGE) }.join
  end
end
end
