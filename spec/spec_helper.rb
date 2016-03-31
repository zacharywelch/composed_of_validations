$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

ENV["RAILS_ENV"] = "test"

require 'rspec'
require 'active_record'
require 'factory_girl'
require 'composed_of_validations'

# Requires everything in 'spec/support'
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)
ActiveRecord::Base.connection.execute <<SQL
  CREATE TABLE "people" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
                         "name" varchar,
                         "address_street" varchar,
                         "address_city" varchar,
                         "address_state" varchar,
                         "address_zip" varchar);
SQL
