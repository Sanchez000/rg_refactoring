class Account
  attr_accessor :name, :login, :age, :password, :errors, :cards
  PATH_TO_DB = 'accounts.yml'.freeze

  def initialize
    @errors = []
    @cards = []
  end

  def valid?
    @errors = []
    validate_name
    validate_age
    validate_login
    validate_password
    errors.empty?
  end

  def self.find_by_credetials(login, password)
    accounts.detect { |account| login == account.login && password == account.password }
  end

  def destroy(login)
    self.class.accounts.delete_if { |account| login == account.login }
    self.class.save_accounts
  end

  def save
    self.class.accounts << self unless self.class.accounts.include?(self)
    self.class.save_accounts
  end

  def self.accounts
    @accounts ||= File.exist?(PATH_TO_DB) ? YAML.load_file(PATH_TO_DB) : []
  end

  def self.save_accounts
    File.open(PATH_TO_DB, 'w') { |f| f.write accounts.to_yaml }
  end

  private

  def validate_name
    return if check_for_emptiness(@name, 'Name')

    @errors.push(I18n.t(:name_capitalize)) if @name[0].upcase != @name[0]
  end

  def validate_login
    return if check_for_emptiness(@login, 'Login')

    size_checker(@login, 'Login', 4, 20)
    @errors.push(I18n.t(:account_exist)) if self.class.accounts.map(&:login).include?(@login)
  end

  def validate_password
    return if check_for_emptiness(@password, 'Password')

    size_checker(@password, 'Password', 6, 30)
  end

  def validate_age(min = 23, max = 90)
    @errors.push(I18n.t(:wrong_length, name: 'Age', min: min, max: max)) unless @age.between?(23, 90)
  end

  def check_for_emptiness(entity, name)
    @errors.push(I18n.t(:not_present, name: name)) if entity.empty?
    @errors.any?
  end

  def size_checker(entity, name, min, max)
    @errors.push(I18n.t(:wrong_length, name: name, min: min, max: max)) unless entity.length.between?(min, max)
  end
end
