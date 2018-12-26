require 'pry'

module Validators
class Account
  attr_reader :errors

  def initialize
    @errors = []
  end

  def validate(account)
    initialize_account(account)

    validate_name
    validate_age
    validate_login
    validate_password
  end

  def valid?
    @errors.size.zero?
  end

  def puts_errors
    @errors.each { |error| puts error }
    @errors = []
  end

  private

  def initialize_account(account)
    @account = account
    @name = @account.name
    @age = @account.age
    @login = @account.login
    @password = @account.password
  end

  def validate_name
    if @name.empty? || @name[0].upcase != @name[0]
      @errors.push('Your name must not be empty and starts with first upcase letter')
    end
  end

  def validate_login
    size_checker(@login, 'Login', 4, 20)
    @errors.push('Such account is already exists') if @account.accounts.map(&:login).include?(@login)
  end

  def validate_password
    size_checker(@password, 'Password', 6, 30)
  end

  def validate_age
    unless @age.between?(23, 90)
      @errors.push('Your Age must be greeter then 23 and lower then 90')
    end
  end

  def size_checker(entity, entity_name, min_size, max_size)
    @errors.push("#{entity_name} must present") if entity.empty?
    unless entity.length.between?(min_size, max_size)
      @errors.push("#{entity_name} must be greeter then #{min_size} and lower then #{max_size} symbols")
    end
  end
end
end
