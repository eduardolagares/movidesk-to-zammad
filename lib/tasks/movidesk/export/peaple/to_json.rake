namespace :movidesk do
    namespace :export do
        namespace :peaple do
            task :to_json do
                skip = 0

                page = 1
                loop do
                    puts "Consultado pessoas: Página #{page}"
                    success, persons = Movidesk::Person.fetch({ "$skip": skip})
                    
                    raise "Não foi possível consultar as pessoas."  unless success
                    
                    break if persons == []

                    filename = "./exported/movidesk-persons-page-#{page}.json"

                    puts "Gerando arquivo #{filename}"
                    File.open(filename,"w") do |f|
                        f.write(persons.to_json)
                    end

                    skip += persons.size
                    page += 1
                end

                puts "Exportação de pessoas concluída."
            end
        end
    end
end




