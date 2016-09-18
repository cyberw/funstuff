require "selenium-webdriver"
require 'yaml'

ENV['PATH'] = ENV['PATH'] + ':.'
EXECUTE = ENV.fetch 'EXECUTE', false

$driver = Selenium::WebDriver.for :chrome

# at_exit { $driver.quit }

$driver.navigate.to ENV['FUNSTUFF']

wait = Selenium::WebDriver::Wait.new(timeout: 5)

YAML.load_file("cookies.yml").each do |cookie|
  $driver.manage.add_cookie cookie
end

$driver.navigate.to ENV['FUNSTUFF']

begin
  wait.until { /totalPortfolio/.match($driver.page_source) } # Not logged in
rescue
  $driver.navigate.to ENV['FUNSTUFF_LOGIN']
  element = $driver.find_element(:name, 'j_username')
  sleep 1
  element.send_keys ENV['FARG']
  element = $driver.find_element(:name, 'j_password')
  sleep 1
  element.send_keys ENV['GARF']
  sleep 1
  element.submit
  File.open("cookies.yml", 'w') do |f|
    f.write YAML.dump($driver.manage.all_cookies)
  end
end

def order(action, instrument, amount, limit)
  $driver.find_element(class: "search-control__control").click
  $driver.find_element(class: "search-control__control").clear
  $driver.find_element(class: "search-control__control").send_keys instrument
  sleep 1
  $driver.find_element(class: "quick-order-search__products-list-item-title").click
  sleep 1
  $driver.find_element(css: "[data-action='#{action}']").click
  $driver.find_element(css: "[data-ng-model='orderData.number']").send_keys amount.to_s
  $driver.find_element(css: "[data-ng-model='orderData.limit']").send_keys limit.to_s

  if EXECUTE == 'true'
    $driver.find_element(class: "order-products-form__button").click
    $driver.find_element(class: "order-modal__footer-button_cancel").click
    $driver.find_element(class: "order-modal__footer-button_confirm").click
  end

  $driver.find_element(class: "header__navigation-logo").click
end

order 'buy', 'HMB', 10, 250
order 'buy', 'HMB', 10, 249
