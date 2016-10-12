require "selenium-webdriver"
require 'yaml'
require "sqlite3"

# rubocop:disable Lint/UselessAssignment
ENV['PATH'] = ENV['PATH'] + ':.'
EXECUTE = ENV.fetch 'EXECUTE', false

ask_a = 99999
bid_a = 0

ask_b = 99999
bid_b = 0

$open_instrument = nil

WAIT = Selenium::WebDriver::Wait.new(timeout: 3)

def fe(*args)
  $driver.find_element(*args)
end

def login
  $driver = Selenium::WebDriver.for :chrome

  $driver.navigate.to ENV['FUNSTUFF']

  cookies = YAML.load_file("cookies.yml")
  cookies.each do |cookie|
    $driver.manage.add_cookie cookie
  end if cookies

  $driver.navigate.to ENV['FUNSTUFF']


  begin
    WAIT.until { fe(class: "search-control__control") }
  rescue Selenium::WebDriver::Error::TimeOutError
    $driver.navigate.to ENV['FUNSTUFF_LOGIN']
    element = fe(:name, 'j_username')
    sleep 1
    element.send_keys ENV['FARG']
    element = fe(:name, 'j_password')
    sleep 1
    element.send_keys ENV['GARF']
    sleep 1
    element.submit
    File.open("cookies.yml", 'w') do |f|
      f.write YAML.dump($driver.manage.all_cookies)
    end
    WAIT.until { fe(class: "search-control__control") }
  end
end

def open_i(instrument)
  # Create a table

  # Find a few rows
#  $db.execute( "select * from numbers" ) do |row|
#    p row
#  end

  fe(class: "search-control__control").click
  fe(class: "search-control__control").clear
  fe(class: "search-control__control").send_keys instrument
  sleep 1
  fe(class: "quick-order-search__products-list-item-title").click
  WAIT.until { fe(class: "product-info__bbo-info-item-value") }
  $db.execute "insert into numbers values ( CURRENT_TIMESTAMP, ?, ?, ? )", [instrument]
  $open_instrument = instrument
end

def order(instrument, amount, limit)
  action = amount < 0 ? 'sell' : 'buy'
  open_i(instrument) if $open_instrument != instrument
  fe(css: "[data-action='#{action}']").click
  fe(css: "[data-ng-model='orderData.number']").send_keys amount.to_s
  fe(css: "[data-ng-model='orderData.limit']").send_keys limit.to_s

  puts "#{instrument},#{amount},#{limit},#{EXECUTE}"

  if EXECUTE == 'true'
    fe(class: "order-products-form__button").click
    fe(class: "order-modal__footer-button_cancel").click
    fe(class: "order-modal__footer-button_confirm").click
  else
    fe(class: "quick-order-popup__close").click
  end
  sleep 5
end

def go_home
  fe(class: "header__navigation-logo").click
  $open_instrument = nil
end
