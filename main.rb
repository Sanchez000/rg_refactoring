require 'i18n'
require 'yaml'
require_relative 'app/entitys/console'
require_relative 'app/entitys/account'
require_relative 'app/entitys/transaction'
require_relative 'app/credits_cards/credit_cards'


I18n.load_path << Dir[File.expand_path('app/config/locales') + '/*.yml']
I18n.default_locale = :en

Console.new.hello
