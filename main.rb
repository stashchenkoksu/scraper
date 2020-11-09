# frozen_string_literal: true

require_relative 'lib/pars'
require 'csv'

site = Parser.new('https://www.onliner.by/')
links = site.all_news_links(/([\d]){4}.([\d]){2}.([\d]){2}/)
news = []
links.each do |link|
  site.open_page(link)
  title = site.get_title(html_element: :class, element_name: 'news-header__title')
  img = site.get_image(html_element: :class, element_name: 'news-header__image')
  text = site.get_text(html_element: :class, element_name: 'news-text')
  news.push({
              title: title,
              image: img,
              text: text
            })
end

CSV.open('data/data.csv', 'w', write_headers: true, headers: news.first.keys) do |csv|
  news.each do |item|
    csv << item.values
  end
end
