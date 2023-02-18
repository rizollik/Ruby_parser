require 'open-uri'
require 'nokogiri'
require 'csv'
require 'net/http'
require 'json'

class Parser
  def initialize
    p "Введите путь к csv файлу, куда будет записан итоговый результат. Пример: C:/Ruby/test_task.csv"
    @filepath = gets.chomp
    p "Введите ссылку на категорию. Пример: https://www.petsonic.com/dermatitis-y-problemas-piel-para-perros/"
    @link_cat = gets.chomp
  end

  def scraping_url
    @link_cat += '?p='
    x = 1
    array_urls = []
    loop do
      url_tmp = @link_cat + x.to_s
      x += 1
      html = URI.open(url_tmp).read
      doc = Nokogiri::HTML(html)
      break if array_urls.include?((doc.search("//a[@class='product-name']/@href")[0]).text) == true || x == 10 # проверка на повторное открытие последней страницы или на максимальное количество продуктов ~240

      doc.search("//a[@class='product-name']/@href").each do |element|
        element = element.text
        array_urls << element
      end
    end

    puts "Этап получения ссылок на продукты окончен."
    case array_urls.length
      when 0 then puts "Массив с ссылками пустой."
      else
        puts "Массив с ссылками непустой."
      end
    return array_urls
  end

  def scraping_prod(urls)
    array_npi = [] # Массив с хешами для каждого продукта. Ключи хеша Name, Price, Image
    urls.each do |link|
      name_temp, img_temp, price_temp = [], '', []
      html = URI.open(link).read
      doc = Nokogiri::HTML(html)
      pr_name = doc.search("//h1[@class='product_main_name']").text
      img_temp = doc.search("//img[@id='bigpic']/@src").text

      if doc.search("//label[contains(@class, 'label_comb_pric')]/span[@class='price_comb']").text != ''
        doc.search("//label[contains(@class, 'label_comb_pric')]/span[@class='radio_label']").each do |option|
          name_temp << pr_name + ' ' + option.text
        end
        doc.search("//label[contains(@class, 'label_comb_pric')]/span[@class='price_comb']").each do |price|
          price_temp << price.text
        end
      else
        pr_id = doc.search("//div[@class='yotpo bottomLine']/@data-product-id").text
        url_res = "https://www.petsonic.com/?fc=module&module=oct8ne&controller=oct8neconnector&octmethod=productinfo&productIds=#{pr_id}"
        uri = URI(url_res)
        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPSuccess) == true
          res = res.body
          res_p = JSON.parse(res)
          res_p[0]["variations"].each do |a|
            price_temp << a["formattedPrice"]
            a_attr = a["attributes"]
            name_temp << pr_name + ' ' + a_attr[0].values.join('') + ' ' + a_attr[0].keys.join('') 
          end
        else
          puts "Получили плохой респонс код у прода с ссылкой:"
          puts link
        end
      end
      name_temp.zip(price_temp).map do |a, b|
        array_npi << {
        Name: a,
        Price: b,
        Image: img_temp
        }
      end
    end
    puts "Этап распаршивания продуктов окончен."
    case array_npi.length
      when 0 then puts "Массив с информацией о продуктах пустой."
      else
        puts "Массив с информацией о продуктах непустой."
    end
    return array_npi
  end

  def csv_file(array_npi)
    CSV.open(@filepath, 'wb') do |csv|
      csv << ['Name', 'Price', 'Image']
      array_npi.each do |hash|
        csv << hash.values
      end
    end
    puts "Файл записан."
  end
end

a = Parser.new
a.csv_file(a.scraping_prod(a.scraping_url))