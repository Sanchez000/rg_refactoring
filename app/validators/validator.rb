class AccountValidator < Account
  def validate_name
    return if check_for_emptiness(@name, 'Name')

    @errors.push(I18n.t(:name_capitalize)) if @name[0].upcase != @name[0]
  end

  def validate_login
    return if check_for_emptiness(@login, 'Login')

    size_checker(@login, 'Login', 4, 20)
    @errors.push(I18n.t(:account_exist)) if accounts.map(&:login).include?(@login)
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
