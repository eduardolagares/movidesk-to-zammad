namespace :zammad do
    namespace :import do
        namespace :peaple do
            task :from_json do

                raise "O parâmetro start_page deve ser informado." if ENV["start_page"].nil?
                raise "O parâmetro total_pages deve ser informado." if ENV["total_pages"].nil?

                page = ENV["start_page"].to_i
                max_pages = ENV["total_pages"].to_i

                json_paths = './exported/'

                while page <= max_pages
                    file_path = json_paths + "movidesk-tickets-page-#{page}.json"
                    file = File.read(file_path)
                    tickets = JSON.parse(file)

                    puts "Importando #{tickets.size} tickets"
                    loop_count = 1
                    tickets.each do |ticket|
                        movidesk_ticket_id = ticket["id"]
                    
                        puts "---------------------------------------------------------"
                        puts "Ticket #{loop_count}/#{tickets.size}"
                        puts "Iniciando a migração do ticket: #{movidesk_ticket_id}"
                        puts "Verificando se o ticket já existe no Zammad..."
                    
                        search_tickets = Zammad::Ticket.search("movidesk_ticket_identificator:#{movidesk_ticket_id}")

                        raise 'Não foi possível conectar a API do Zammad' && next if tickets.nil?

                        if !search_tickets.size.zero?
                            puts "O ticket #{movidesk_ticket_id} já existe Zammad!!!!!!!!!!!"
                        else
                            # Cria o ticket
                            puts "Criando o ticket no Zammad..."

                            puts "Pesquisando o usuário no Zammad..."


                            users_search = Zammad::User.search("identificador_movidesk:#{ticket["clients"].first["id"]}")

                            raise "Não foi possível encontrar o usuário #{ticket["clients"].first["id"]} no Zammad!!!!" if users_search == []

                            zammad_user_id = users.first["id"]

                #             binding.pry

                #             first_action = ticket["actions"].first
                #             ticket_params = {
                #                 movidesk_ticket_identificator: movidesk_ticket_id,
                #                 title: ticket["subject"],
                #                 customer_id: ticket_customer["id"],
                #                 state_id: Zammad::Ticket.map_status(ticket["status"]),
                #                 article: {
                #                     body: first_action.dig("htmlDescription"),
                #                     content_type: "text/html",
                #                     internal: first_action.dig("type") == 1

                #                 }
                #             }
                #             result = Zammad::Ticket.create(ticket_params)
                #             binding.pry
                #             if result
                #                 puts "Ticket #{movidesk_ticket_id} criado no Zammad com sucesso."
                #                 ticket["actions"].size > 1

                #                 puts "Gerando ações do ticket"
                #             else
                #                 puts ticket_params.inspect
                #                 raise "Não foi possível criar o ticket #{identificador_movidesk} no Zammad!!!!!!!"
                #             end
                        end

                        loop_count += 1
                    end

                    page += 1

                end
            end
        end
    end
end

