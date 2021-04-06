
module Movidesk
    class Person
        def self.fetch(params)
            url = "#{ENV['MOVIDESK_API_BASE_URL']}/persons"

            params[:token] = ENV['MOVIDEKS_API_KEY']
            params["$orderby"] = 'businessName'
            params["$select"] = "id,businessName,emails"
            params["$expand"] = "emails($select=email,isDefault)"
           
            response = Faraday.get url, params

            [response.success?, JSON.parse(response.body)]
        end
    end
end