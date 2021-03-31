namespace :movidesk do
    namespace :export do
        namespace :peaple do
            task :to_json do
                email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

                skip = 0

                page = 1
                loop do
                    puts "Consultado pessoas: Página #{page}"
                    persons = Movidesk::Person.fetch({ "$skip": skip})
                    
                    break if persons == [] || persons == nil

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




