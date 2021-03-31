module Zammad
    class Ticket
        def self.search(query)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}tickets/search"
            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
            params = {
                query: query,
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
            url = "#{ENV['ZAMMAD_API_BASE_URL']}tickets"

            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
        
            response = Faraday.post url, params, headers

            raise response.inspect unless response.success? 
            JSON.parse(response.body)
        end


        def self.map_status(movidesk_status)
            case movidesk_status
            when 'Novo'
                1 # new
            when 'Cancelado'
                11 # canceld
            when 'Fechado'
                4 # closed
            else
                raise "O status #{movidesk_status} não foi mapeado em Zammad::Ticket.map_status"
            end
        end

    end
end