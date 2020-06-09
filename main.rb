# # frozen_string_literal: true
require 'nokogiri'
require 'curb'
require "sqlite3"
require 'rubygems'
require 'image_downloader'

db = SQLite3::Database.new "test.sqlite3"
db.execute("CREATE TABLE IF NOT EXISTS food_sector (id INTEGER PRIMARY KEY AUTOINCREMENT, sector_name string)")
db.execute(
    "CREATE TABLE IF NOT EXISTS recipes (id INTEGER PRIMARY KEY AUTOINCREMENT, food_sector_id INTEGER, "+
    +"sector_name string, discription string, create_time string, source string)")
db.execute("CREATE TABLE IF NOT EXISTS steps (id INTEGER PRIMARY KEY AUTOINCREMENT, primary_id INTEGER, image_url string, text string)")

url = 'https://eda.ru/recepty'


puts('Parsing categories...')

categories = {}
$sector_count = 0
doc = Nokogiri::HTML(Curl.get(url).body_str)
# print doc
links = doc.search('li.seo-footer__list-title  a').map { |link| link['href'] }


def take_links(category_name, doc, link, index)
    links_on_page = doc.search("h3[@class='horizontal-tile__item-title item-title'] a").map { |link| link['href'] }
    links_on_page.each do |link_on_page|
        if !link_on_page.include?(category_name)
            links_on_page.delete(link_on_page)            
        end
    end
end



links.each_with_index do |link, index|
    category_name = link[23..-1]
    categories[category_name] = {}
    # db.execute("INSERT INTO food_sector (sector_name) 
    #         VALUES (?)", [category_name])
    $sector_count += 1
    puts category_name
    doc = Nokogiri::HTML(Curl.get(link).body_str)
    urls = take_links(category_name, doc, link, index)
    links_on_page = Array.new()
    urls.each do |t|
        links_on_page << t
    end
    link = link+'?page='+'2'
    i = 2
    until urls.empty?
        doc = Nokogiri::HTML(Curl.get(link).body_str)
        urls = take_links(category_name, doc, link, index)
        urls.each do |t|
            links_on_page << t
        end
        i += 1
        link = link[0..link.index('=')] + i.to_s
    end


    links_on_page.each do |recipe_url|
        doc = Nokogiri::HTML(Curl.get('https://eda.ru'+recipe_url).body_str)
        recipe_name = doc.search("h1[@class='recipe__name g-h1']").xpath('text()')
        kitchen = doc.search("div.recipe__title ul[@class='breadcrumbs'] li a").map { |item| item.xpath('text()') }.last.to_s
        portions = doc.search("input[@class='portions-control__count g-h6 js-portions-count js-tooltip']").map { |item| item['value'] }.first.to_s

        discription = doc.search("p[@class='recipe__description layout__content-col corner-label__gold-thousand-mod']").xpath('text()')
        puts discription
        food_part = doc.search("div.ingredients-list__content p[@class='ingredients-list__content-item content-item js-cart-ingredients']")#.map { |item| item['value'] }
        food_parts = ''
        food_part.each do |item|
            name =  item.search("span[@class='js-tooltip js-tooltip-ingredient']").map { |item| item.xpath('text()') }.last.to_s
            amount = item.search("span[@class='content-item__measure js-ingredient-measure-amount']").map { |item| item.xpath('text()') }.last.to_s
            food_parts += "#{name} #{amount}\n"    
        end
        # steps
        instruction = doc.search("div.recipe__instruction li[@class='instruction clearfix js-steps__parent print-preview']")#.map { |item| item.xpath('text()') }
        discriptions = instruction.search("span[@class='instruction__description js-steps__description ']").map { |item| item.xpath('text()').to_s } # discriptions
        imgs = instruction.search("img[@class='g-print-visible']").map{ |i| 'https:'+ i['src'] }.uniq # imgs
        begin  
            Dir.mkdir recipe_name.to_s
        rescue
        end 
        puts imgs_urls
        imgs.each_with_index do |photo, number|
            File.open("#{recipe_name.to_s}/#{number}", "wb") do |f|
                f.write(open(photo).read)
            end
        end

        break
    end
    break
end

puts 'Work completed successfully'