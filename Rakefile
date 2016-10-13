require_relative 'support'
require "sqlite3"

`killall 'Google Chrome' 2>/dev/null`
$db = SQLite3::Database.new("funstuff.db")
$driver = Selenium::WebDriver.for(:chrome)

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
  ask_b = fe(xpath: '//span[@data-dg-watch-property="LastPrice"]').text
#   ask_b = fe(class: "product-info__bbo-info-item-value").text
  puts 'ask_b ' + ask_b

#  order 'HMB', 10, 250.1
#  order 'HMB', -10, 249.5
#  $driver.quit
end
