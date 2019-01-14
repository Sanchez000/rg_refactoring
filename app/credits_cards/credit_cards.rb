require 'yaml'
require 'pry'

class CreditCards
  TYPES = {
    'usual' => { balance: 50.00 },
    'capitalist' => { balance: 100.00 },
    'virtual' => { balance: 150.00 }
  }.freeze

  attr_accessor :type, :number, :balance

  def initialize(type)
    @type = type
    @number = generate_number
    @balance = TYPES.dig(type, :balance)
  end

  private

  def generate_number
    Array.new(16) { rand(10) }.join
  end
end
