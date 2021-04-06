namespace :zammad do
    namespace :import do
        namespace :tickets do
            task :from_json do

                # raise "O parâmetro start_page deve ser informado." if ENV["start_page"].nil?
                # raise "O parâmetro total_pages deve ser informado." if ENV["total_pages"].nil?
                # raise "O parâmetro group_id deve ser informado." if ENV["group_id"].nil?

                start_page = ENV["start_page"].to_i
                total_pages = ENV["total_pages"].to_i
                group_id = ENV["group_id"].to_i
                movidesk_id_field_name = ENV['ZAMMAD_MOVIDEKS_ID_FIELD_NAME']

                export_path = './exported/'
                
                zammad_tickets_importer = Zammad::ImportTickets.new({
                    start_page: start_page, 
                    total_pages: total_pages, 
                    group_id: group_id, 
                    movidesk_id_field_name: movidesk_id_field_name, 
                    export_path: export_path
                })

                result = zammad_tickets_importer.call

                raise result.message unless result.success?
                    

                
            end
        end
    end
end

