
module Movidesk
    class Ticket
        def self.fetch(params)
            url = "#{ENV['MOVIDESK_API_BASE_URL']}/tickets"

            params[:token] = ENV['MOVIDEKS_API_KEY']
            # params["$select"] = "id,subject,owner,clients,urgency,category,status,createdDate,isDeleted,ownerTeam,justification"
            params["$select"] = "id,clients"
            params["$expand"] = 'clients($select=id,email,businessName)'
            params["$top"] = 1000

            # ,attachments($select=fileName,path,createdBy,createdDate)
           
            response = Faraday.get url, params

            [response.success?, JSON.parse(response.body)]
        end

        def self.fetch_by_id(id)
            url = "#{ENV['MOVIDESK_API_BASE_URL']}/tickets"
            params = {
                token: ENV['MOVIDEKS_API_KEY'],
                id: id
            }
            # params[:token] = 
            # params[:id] = id
            # # params["$select"] = "id,subject,owner,clients,urgency,category,status,createdDate,isDeleted,ownerTeam,justification"
            # # params["$expand"] = 'owner($select=businessName,email),clients($select=id,businessName,email,phone),actions($select=description,htmlDescription,status,isDeleted,createdDate,createdBy,attachments)'
            # # params["$top"] = 1000

            # ,attachments($select=fileName,path,createdBy,createdDate)
           
            response = Faraday.get url, params

            [response.success?, JSON.parse(response.body)]
        end


    end
end