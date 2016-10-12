require_relative 'support'
require "sqlite3"

# Open a database
$db = SQLite3::Database.new("funstuff.db")

desc 'init db'
file 'funstuff.db' do
  $db.execute <<-SQL
    create table numbers (
      time datetime,
      instrument varchar(30),
      buy int,
      sell int
    );
  SQL
end

desc 'stuff here'
task :default do
  login
  open_i 'HMB'
  ask_b = fe(class: "product-info__bbo-info-item-value").text
  puts 'ask_b ' + ask_b

  order 'HMB', 10, 250.1
  order 'HMB', -10, 249.5
  $driver.quit
end
