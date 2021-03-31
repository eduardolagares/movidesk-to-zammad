
module Movidesk
    class Person
        def self.fetch(params)
            url = "#{ENV['MOVIDESK_API_BASE_URL']}/persons"

            params[:token] = ENV['MOVIDEKS_API_KEY']
            params["$orderby"] = 'businessName'
           
            response = Faraday.get url, params

            if response.success?
                JSON.parse(response.body)
            else
                nil
            end
        end
    end
end