# frozen_string_literal: true
require 'csv'
require 'nokogiri'
require 'curb'

url = 'https://eda.ru/recepty'


puts('Parsing categories...')

categories = {}


doc = Nokogiri::HTML(Curl.get(url).body_str)
# print doc
links = doc.search('li.seo-footer__list-title  a').map { |link| link['href'] }


def take_links(category_name, doc, link, index)
    links_on_page = doc.search("h3[@class='horizontal-tile__item-title item-title'] a").map { |link| link['href'] }
    links_on_page.each_with_index do |link_on_page|
        if !link_on_page.include?(category_name)
            
            links_on_page.delete(link_on_page)            
        end
    end
end



links.each_with_index do |link, index|
    category_name = link[23..-1] # category name
    puts "\n"+ category_name
    categories[category_name] = {}
    doc = Nokogiri::HTML(Curl.get(link).body_str)
    urls = take_links(category_name, doc, link, index)
    links_on_page = Array.new()
    urls.each do |t|
        links_on_page << t
    end
    link = link+'?page='+'2'
    i = 2
    until urls.empty?
        puts link
        doc = Nokogiri::HTML(Curl.get(link).body_str)
        urls = take_links(category_name, doc, link, index)
        urls.each do |t|
            links_on_page << t
        end
        i += 1
        link = link[0..link.index('=')] + i.to_s
    end
    # puts links
    
    puts links_on_page.length
    
    # break



end


# links_on_pages.push(links)
# i = 2

# until links.empty?
#   # puts url
#   if url.include?('/?p=') && url[-1] != '/'
#     url = url[0, url.length - 1] + (url[-1].to_i + (2 - 1)).to_s
#   elsif url[-1] == '/'
#     url = url + '?p=' + i.to_s
#   elsif !url.include?('/?p=') && url[-1] != '/'
#     doc = Nokogiri::HTML(Curl.get(url).body_str)
#     links = doc.search('div.pro_outer_box a.product-name').map { |link| link['href'] }
#     links_on_pages.push(links)
#     break 
#   end

#   doc = Nokogiri::HTML(Curl.get(url).body_str)
#   links = doc.search('div.pro_outer_box a.product-name').map { |link| link['href'] }
#   links_on_pages.push(links)
#   i += 1
# end

# puts "Page count: #{links_on_pages.length - 1}"

# CSV.open("#{csv_name}.csv", 'wb') do |csv|
#   puts 'CSV file has been created'

#   csv << %w[Name Price Image]

#   links_on_pages[0, links_on_pages.length - 1].each_with_index do |links, item_index|
    
#     puts "Searching on page №#{item_index + 1}"

#     links.each do |link|
#       doc = Nokogiri::HTML(Curl.get(link).body_str)
      
#       name = doc.search('h1.product_main_name').xpath('text()')
#       prices = doc.search('span.price_comb').map { |item| item.xpath('text()') }
#       image = doc.search('img#bigpic').map { |item| item['src'] }
      
#       doc.search('span.radio_label').map { |item| item.xpath('text()') }.each_with_index do |item, price_item|
#         csv << ["#{name} #{item}", prices[price_item], image[0]]
#       end
#     end

#     puts "Page №#{item_index + 1} finished"
#   end
# end

puts 'Work completed successfully'