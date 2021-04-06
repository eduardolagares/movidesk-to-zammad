module Zammad
    class ImportTickets
        include Interactor

        def call
            
            validar_parametros

            while context.start_page <= context.max_pages
                file_path = context.export_path + "movidesk-tickets-page-#{context.start_page}.json"
                file = File.read(file_path)
                tickets = JSON.parse(file)

                puts "===================================================================================================="
                puts "Importando #{tickets.size} tickets da página #{context.start_page}"
                puts "===================================================================================================="

                loop_count = 0
                tickets.each do |ticket|
                    loop_count += 1
                    next if context.start_index.to_i > loop_count
                    
                    puts "PÁGINA: #{context.start_page} LOOP: #{loop_count}"
                    
                    import_ticket_result = Zammad::ImportTicket.call(ticket: ticket, group_id: context.group_id, movidesk_id_field_name: context.movidesk_id_field_name)
                    
                    context.fail!(message: import_ticket_result.message) unless import_ticket_result.success?
                end

                context.total_pages -= 1
                context.start_index = 0
                context.start_page += 1

            end
        end

        private

    

        def validar_parametros

            context.fail! message: "O parâmetro start_page deve ser informado." if context.start_page.nil?
            context.fail! message: "O parâmetro total_pages deve ser informado." if context.total_pages.nil?
            context.fail! message: "O parâmetro group_id deve ser informado." if context.group_id.nil?
            context.fail! message: "O parâmetro groupmovidesk_id_field_name_id deve ser informado." if context.movidesk_id_field_name.nil?
            context.fail! message: "O parâmetro export_path deve ser informado." if context.export_path.nil?


            context.max_pages = context.start_page + context.total_pages
        end
    end
end