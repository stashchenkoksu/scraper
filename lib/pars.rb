# frozen_string_literal: true

require 'selenium-webdriver'
require 'nokogiri'
require 'capybara'

class Parser
  attr_reader :driver, :browser, :url

  def initialize(url)
    init
    @browser = Capybara.current_session
    @driver = browser.driver.browser
    @url = url
    browser.visit url
  end

  def init
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end
    Capybara.javascript_driver = :chrome
    Capybara.configure do |config|
      config.default_max_wait_time = 10 # seconds
      config.default_driver = :selenium
    end
  end

  def open_page(url)
    driver.get(url)
  end

  def all_news_links(regex)
    all_links = browser.all 'li a'
    href_links = []
    all_links.each do |link|
      href_links << link['href'] if link['href'] =~ regex
    end
    href_links.uniq!
  end

  def get_title(html_element:, element_name:)
    driver.find_element(html_element.to_sym, element_name).text
  rescue StandardError
    'default title'
  end

  def get_image(html_element:, element_name:)
    driver.find_element(html_element.to_sym, element_name)['style'] =~ /(?<=\().+?(?=\))/
    Regexp.last_match[0].gsub('"', '')
  rescue StandardError
    'default image'
  end

  def get_text(html_element:, element_name:)
    text = driver.find_element(html_element.to_sym, element_name).text
    text = text.slice(0..199)
    text.slice(0..text.rindex(' '))
  end
end
