module Wikipedia
  class Base
    LANGUAGE_MAP = { 'de' => 'German', 'en' => 'English', 'fr' => 'French', 'hu' => 'Hungarian', 'es' => 'Spanish', 'it' => 'Italian' }

    def get_page_data(title)
      page_data = {}
      item_id = get_item_id(title)
      page_languages = get_page_languages(item_id)
      page_languages.each do |lang, _data|
        country_code = lang.gsub('wiki', '')
        language = LANGUAGE_MAP[country_code]
        next unless language

        page_data[language] = {}
        page_data[language]['page_link'] = "https://#{country_code}.wikipedia.org/wiki/#{title}"
        page_data[language]['word_count'] = get_word_count(country_code, title)
      end
      page_data
    end

    def get_item_id(title)
      uri = URI('https://en.wikipedia.org/w/api.php')
      params = { action: 'query', prop: 'pageprops', format: 'json', origin: '*', titles: title }

      call_api(uri, params, 'wikibase_item')
    end

    def get_page_languages(id)
      uri = URI('https://www.wikidata.org/w/api.php')
      params = { action: 'wbgetentities', props: 'sitelinks', format: 'json', origin: '*', ids: id }

      call_api(uri, params, 'sitelinks')
    end

    def get_word_count(country_code, search)
      uri = URI("https://#{country_code}.wikipedia.org/w/api.php")
      params = { format: 'json', origin: '*', action: 'query', list: 'search', srwhat: 'nearmatch', srlimit: '1', srsearch: search }

      call_api(uri, params, 'wordcount')
    end

    private
      def call_api(uri, params, key)
        uri.query = URI.encode_www_form(params)

        res = Net::HTTP.get_response(uri)
        if res.is_a?(Net::HTTPSuccess)
          nested_hash_value(JSON.parse(res.body), key)
        else
          res.body
        end
      end

      def nested_hash_value(obj, key)
        if obj.respond_to?(:key?) && obj.key?(key)
          obj[key]
        elsif obj.respond_to?(:each)
          r = nil
          obj.find{ |*a| r=nested_hash_value(a.last,key) }
          r
        end
      end
  end
end
