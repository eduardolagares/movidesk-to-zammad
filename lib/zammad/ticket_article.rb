module Zammad
    class TicketArticle
        def self.fetch_by_ticket(ticket_id)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}ticket_articles/by_ticket/#{ticket_id}"
            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
            params = {
                limit: 1,
                expand: true
            }

            response = Faraday.get url, params, headers

            [response.success?, JSON.parse(response.body)]
        end

        def self.create(params)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}ticket_articles"

            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
        
            response = Faraday.post url, params, headers

            [response.success?, JSON.parse(response.body)]
        end

        def self.update(data)
            url = "#{ENV['ZAMMAD_API_BASE_URL']}ticket_articles/#{data["id"]}"

            headers = {
                'Authorization': "Token token=#{ENV['ZAMMAD_API_KEY']}"
            }
        
            response = Faraday.put url, data, headers

            [response.success?, JSON.parse(response.body)]
        end


    end
end