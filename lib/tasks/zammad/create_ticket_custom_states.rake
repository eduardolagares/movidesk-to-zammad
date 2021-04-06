
namespace :zammad do
    task :create_ticket_custom_states do
        

        success_field1, result_field1 = Zammad::TicketState.create({
          "name": "Canceled",
          "state_type_id": 4,
          "ignore_escalation": true,
          "active": true,
          "note": "Status resolvido"
        })

        success_field1, result_field1 = Zammad::TicketState.create({
          "name": "Resolvido",
          "state_type_id": 4,
          "ignore_escalation": true,
          "active": true,
          "note": "Status Resolvido"
        })


        
        raise "Não foi possível criar o TicketState. #{result_field1.inspect}" unless success_field1

        
        puts "Ticket state #{result_field1.inspect} criado com sucesso"


    end
end

