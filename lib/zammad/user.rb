module Zammad
    class User
        def self.search(email)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}users/search"
            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
            params = {
                query: email,
                limit: 1,
                expand: true
            }

            response = Faraday.get url, params, headers
            if response.success?
                JSON.parse(response.body)
            else
                nil
            end
        end

        def self.create(params)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}users"

            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
        
            response = Faraday.post url, params, headers
            [response.success?, response]
        end
    end
end