module Zammad
    class TicketState

        def self.create(params)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}ticket_states"

            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
        
            response = Faraday.post url, params, headers

            [response.success?, JSON.parse(response.body)]
        end


    end
end