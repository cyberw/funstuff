require "selenium-webdriver"
require 'yaml'

ENV['PATH'] = ENV['PATH'] + ':.'
EXECUTE = ENV.fetch 'EXECUTE', false

def fe(*args)
  $driver.find_element(*args)
end

$driver = Selenium::WebDriver.for :chrome

# at_exit { $driver.quit }

$driver.navigate.to ENV['FUNSTUFF']

wait = Selenium::WebDriver::Wait.new(timeout: 3)

YAML.load_file("cookies.yml").each do |cookie|
  $driver.manage.add_cookie cookie
end

$driver.navigate.to ENV['FUNSTUFF']

begin
  wait.until { fe(class: "search-control__control") }
rescue
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
  wait.until { fe(class: "search-control__control") }
end


def order(instrument, amount, limit)
  action = amount < 0 ? 'sell' : 'buy'
  fe(class: "search-control__control").click
  fe(class: "search-control__control").clear
  fe(class: "search-control__control").send_keys instrument
  sleep 1
  fe(class: "quick-order-search__products-list-item-title").click
  sleep 1
  fe(css: "[data-action='#{action}']").click
  fe(css: "[data-ng-model='orderData.number']").send_keys amount.to_s
  fe(css: "[data-ng-model='orderData.limit']").send_keys limit.to_s

  puts "#{instrument},#{amount},#{limit},#{EXECUTE}"

  if EXECUTE == 'true'
    fe(class: "order-products-form__button").click
    fe(class: "order-modal__footer-button_cancel").click
    fe(class: "order-modal__footer-button_confirm").click
  end
  sleep 5
  fe(class: "header__navigation-logo").click
end

order 'HMB', 10, 250.1
order 'HMB', -10, 249.5
