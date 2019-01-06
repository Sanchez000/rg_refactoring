require_relative 'credits_cards/base'
require_relative 'credits_cards/usual'
require_relative 'credits_cards/capitalist'
require_relative 'credits_cards/virtual'

class CreditCard
  attr_reader :card
  VALID_TYPES = %w[
    usual
    capitalist
    virtual
  ].freeze

  def initialize(type)
    case type
    when 'usual' then @card = CreditCards::Usual.new
    when 'capitalist' then @card = CreditCards::Capitalist.new
    when 'virtual' then @card = CreditCards::Virtual.new
    end
  end
end
