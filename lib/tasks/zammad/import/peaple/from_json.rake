namespace :zammad do
    namespace :import do
        namespace :peaple do

            task :import_person, [:email, :name, :identificador_movidesk, :loop_count, :persons_count, :page] do |task, args|

                    email = args[:email]
                    name = args[:name]
                    identificador_movidesk = args[:identificador_movidesk]
                    loop_count = args[:loop_count]
                    persons_count = args[:persons_count]
                    page = args[:page]

                    
                    # url = ENV["ZAMMAD_API_BASE_URL"] + "users"

                    # curl_string = "curl -i -H \"Accept: application/json\" -H \"Authorization: Token token=#{ENV['ZAMMAD_API_KEY']}\" -d '{\"email\":\"#{email}\", \"firstname\":\"#{name}\", \"#{ENV["ZAMMAD_MOVIDEKS_ID_FIELD_NAME"]}\":\"#{identificador_movidesk}\"}' -H \"Content-Type: application/json\" -X POST #{url}"
                    # puts curl_string
                    # Kernel.system curl_string
                    # exec curl_string

                    puts "---------------------------------------------------------"
                    puts "Pessoa #{loop_count}/#{persons_count} da página #{page}"
                    puts "Iniciando a migração da pessoa: #{name} - #{email} - ID: #{identificador_movidesk}"

                    user_params = {
                        email: email,
                        firstname: name,
                        "#{ENV["ZAMMAD_MOVIDEKS_ID_FIELD_NAME"]}": identificador_movidesk
                    }

                    puts "Criando a pessoa no Zammad..."
                    
                    success, result = Zammad::User.create(user_params)

                    if success
                        puts "Pessoa #{email} criado no Zammad com sucesso."
                    else
                        if result.dig("error")&.include?("is already used for other user.")
                            puts "Usuário #{email} já existe no Zammad !!!!!."
                        else
                            raise "Não foi possível criar o usuário #{email} no Zammad!!!!!!!"
                        end
                    end
                
            end

            task :from_json do
                
                

                    raise "O parâmetro start_page deve ser informado." if ENV["start_page"].nil?
                    raise "O parâmetro total_pages deve ser informado." if ENV["total_pages"].nil?

                    email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

                    start_index = ENV["start_index"].nil? ? 1 : ENV["start_index"].to_i
                    
                    page = ENV["start_page"].to_i
                    total_pages = ENV["total_pages"].to_i
                    max_pages = page + total_pages - 1

                    json_paths = './exported/'

                    pool = Thread.pool(10)

                    while page <= max_pages
                        file_path = json_paths + "movidesk-persons-page-#{page}.json"
                        file = File.read(file_path)
                        persons = JSON.parse(file)
                        persons_count = persons.size

                        if start_index > 0
                            persons = persons[(start_index-1)..persons_count]
                        end

                        
                        loop_count = start_index
                        
                        puts "Importando #{persons_count} pessoas da página #{page}"

                        persons.each do |person|
                            email = person["emails"].first&.dig("email")
                            name = person['businessName'] || person['userName']
                            identificador_movidesk = person['id']

                            unless email =~ email_regex
                                email = "movidesk-cliente-importado-#{identificador_movidesk}@baladapp.com.br"
                            end

                            Rake::Task['zammad:import:peaple:import_person'].execute(
                                email: email, 
                                name: name, 
                                identificador_movidesk: identificador_movidesk, 
                                loop_count: loop_count, 
                                persons_count: persons_count, 
                                page: page
                            )
                            
                            loop_count += 1

                        end

                        page += 1
                        start_index = 1
                    end

                pool.shutdown
            end
        end
    end
end

