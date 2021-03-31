
module Movidesk
    class Ticket
        def self.fetch(params)
            url = "#{ENV['MOVIDESK_API_BASE_URL']}/tickets"

            params[:token] = ENV['MOVIDEKS_API_KEY']
            params["$select"] = "id,subject,owner,clients,urgency,category,status,createdDate,isDeleted,ownerTeam,justification"
            params["$expand"] = 'owner($select=businessName,email),clients($select=id,businessName,email,phone),actions($select=description,htmlDescription,status,isDeleted,createdDate,createdBy)'
            params["$top"] = 1000
           
            response = Faraday.get url, params

            if response.success?
                JSON.parse(response.body)
            else
                nil
            end
        end
    end
end