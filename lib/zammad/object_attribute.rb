module Zammad
    class ObjectAttribute
        

        def self.create(params)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}object_manager_attributes"

            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
        
            response = Faraday.post url, params, headers

            [response.success?, JSON.parse(response.body)]
        end


    end
end