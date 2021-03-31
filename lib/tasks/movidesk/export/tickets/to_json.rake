namespace :movidesk do
    namespace :export do
        namespace :tickets do
            task :to_json do

                skip = 0
                page = 1
                loop do
                    puts "Consultado tickets. Página #{page}"
                    tickets = Movidesk::Ticket.fetch({ "$skip": skip})
                    
                    break if tickets == [] || tickets == nil

                    filename = "./exported/movidesk-tickets-page-#{page}.json"

                    puts "Gerando arquivo #{filename}"
                    
                    File.open(filename,"w") do |f|
                        f.write(tickets.to_json)
                        page+=1
                    end
                    skip += tickets.size
                end

                puts "Exportação de tickets concluída."
            end
        end
    end
end

