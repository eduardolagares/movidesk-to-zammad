namespace :zammad do
    namespace :import do
        namespace :peaple do
            task :from_json do

                raise "O parâmetro start_page deve ser informado." if ENV["start_page"].nil?
                raise "O parâmetro total_pages deve ser informado." if ENV["total_pages"].nil?

                email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

                page = ENV["start_page"].to_i
                max_pages = ENV["total_pages"].to_i

                json_paths = './exported/'

                while page <= max_pages
                    file_path = json_paths + "movidesk-persons-page-#{page}.json"
                    file = File.read(file_path)
                    persons = JSON.parse(file)

                    puts "Importando #{persons.size} pessoas da página #{page}"
                    loop_count = 1
                    persons.each do |person|
                        email = person["emails"].first&.dig("email")
                        name = person['businessName'] || person['userName']
                        identificador_movidesk = person['id']

                        unless (email =~ email_regex)
                            puts "Pessoa com e-mail inválido!!! EMAIL: #{email}"
                            next
                        end
                    
                        puts "---------------------------------------------------------"
                        puts "Pessoa #{loop_count}/#{persons.size} da página #{page}"
                        puts "Iniciando a migração da pessoa: #{name} - #{email} - ID: #{person["id"]}"
            
                        puts "Criando a pessoa no Zammad..."
                        user_params = {
                            email: email,
                            firstname: name,
                            identificador_movidesk: identificador_movidesk
                        }
                        success, response = Zammad::User.create(user_params)

                        if success
                            puts "Usuário #{email} criado no Zammad com sucesso."
                        else
                            json = JSON.parse(response.body)
                            if json.dig("error")&.include?("is already used for other user.")
                                puts "Usuário #{email} já existe no Zammad !!!!!."
                            else
                                "Não foi possível criar o usuário #{email} no Zammad!!!!!!!"
                            end
                        end

                        loop_count += 1
                    end

                    page += 1
                end
            end
        end
    end
end

