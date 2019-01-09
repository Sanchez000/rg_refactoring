require 'i18n'
require 'yaml'
require_relative 'app/console'

I18n.load_path << Dir[File.expand_path('app/config/locales') + '/*.yml']
I18n.default_locale = :en

Console.new.hello
