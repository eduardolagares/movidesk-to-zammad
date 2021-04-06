module Zammad
    class ImportTicket
        include Interactor

        def call

            puts "------------------------------------------------------------------------"
            
            context.movidesk_ticket_id = context.ticket["id"]
            context.movidesk_user_email = context.ticket["clients"].first["email"]
            context.movidesk_user_id = context.ticket["clients"].first["id"]
            context.movidesk_user_name = context.ticket["clients"].first["businessName"]
            context.movidesk_user_created_at = context.ticket["clients"].first["createdDate"]

            # verifica se  ticekt existe no Zammad
            search_ticket_in_zammad

            # Busca os detalhes do ticket no Movidesk
            fetch_movidesk_ticket_detail
    
            puts "O ticket #{context.movidesk_ticket_id} já existe Zammad!"if context.ticket_exists

            # Busca e crie o usuário do ticket
            context.zammad_user = search_user_in_zammad(context.movidesk_user_id, context.movidesk_user_email)
            context.zammad_user ||= create_user_in_zammad(context.movidesk_user_id, context.movidesk_user_email, context.movidesk_user_name, context.movidesk_user_created_at)
            context.zammad_user_id = context.zammad_user["id"]

            # Cria o ticket caso ele ainda não exista
            create_ticket_in_zammad unless context.ticket_exists

            create_ticket_articles_in_zammad
          
            puts "------------------------------------------------------------------------"
        end

        private

        def build_zammad_attachment_filename(movidesk_attachment)
            "#{movidesk_attachment["path"]}---#{movidesk_attachment["fileName"]}"
        end
        
        def download_attachement(filename)
            url = ENV["MOVIDESK_ATTACHEMENTS_BASE_URL"] + filename
            tempfile = Down.download(url)
            data = File.open(tempfile).read
            Base64.encode64(data)
        end

        def get_mimetype_from_filename(filename)
            return "text/plain" if filename == "text.plain"

            type = MIME::Types.type_for(filename)

            context.fail!(message: "impossível identificar o mimetype do arquivo #{filename}") if type.size.zero?
            
            type.first&.content_type
        end

        def create_ticket_article_in_zammad(action)
            article_creator_id = action["createdBy"]["id"]
            article_creator_email = action["createdBy"]["email"]
            article_creator_name = action["createdBy"]["businessName"]
            article_creator_created_at = action["createdDate"] # uso a data da action pq não tenho a info aqui
            
            zammad_user = search_user_in_zammad(article_creator_id, article_creator_email)

            zammad_user ||= create_user_in_zammad(article_creator_id, article_creator_email, article_creator_name, article_creator_created_at)

            changed, attachments = build_attachments_array_from_movidesk_attachments(action["attachments"], [])
            success, result = Zammad::TicketArticle.create({
                ticket_id: context.zammad_ticket_id,
                subject: "movidesk_action_id:#{action["id"]}",
                body: action["htmlDescription"],
                content_type: "text/html",
                internal: action["type"] == 1,
                type: action["type"] == 1 ? 'note' : 'email',
                # type: 'note', # Se eu colocar e-mail ele tenta disparar um e-mail
                attachments: attachments,
                created_at: action["createdDate"]
            })


            context.fail!(message: "Não foi possível criar o artigo: #{result.inspect}") unless success

            puts "Artigo #{result["id"]} criado com sucesso. Este artigo possui #{attachments.size} anexos"

            result
        end


        def create_ticket_articles_in_zammad
            movidesk_actions = context.movidesk_ticket["actions"].drop(1)

            if movidesk_actions.size.zero?
                puts "O ticket MOVIDESK_ID=#{context.movidesk_ticket["id"]} não possui artigos para serem verificados."
                return
            end

            puts "Pesquisando os artigos atuais do ticket no Zammad..."

            success, articles = Zammad::TicketArticle.fetch_by_ticket(context.zammad_ticket_id)
            context.fail!(message: "Não foi possível obter os artigos atuais do ticket #{context.zammad_ticket_id} no Zammad! #{articles.inspect}") unless success

            puts "Comparando artigos (movidesk=#{movidesk_actions.size}) x (zammad=#{articles.size})"
            
            movidesk_actions.each do |action|
                article = search_article_in_articles(action, articles)

                article ||= create_ticket_article_in_zammad(action)

                changed, attachments = build_attachments_array_from_movidesk_attachments(action["attachments"], article["attachments"])

                
                if changed
                    article["attachments"] = attachments
                    article = update_ticket_article_in_zammad(article)
                end
            end
        end

        def update_ticket_article_in_zammad(article)
            success, result = Zammad::TicketArticle.update(article)
            context.fail!(message: "Não foi possível atualizar o TicketArticle #{article["id"]}") unless success

            result
        end

      

        # Aqui o conteúdo é comparado para encontrar o artigo
        def search_article_in_articles(action, articles)
            article =  articles.select{|a| a["subject"] == "movidesk_action_id:#{action["id"]}"}.first
        end

        def build_attachments_array_from_movidesk_attachments(movidesk_attachments, current_attachments)
            result = []
            changed = true

            # ignore filename lists
            ignore_list = ['default-avatar.png']

            movidesk_attachments = movidesk_attachments.select{|a| !ignore_list.include?(a["fileName"])}
            
            return [false, []] if movidesk_attachments.nil? || movidesk_attachments.size.zero?

            # Verifica se existem diferenças
            diff = movidesk_attachments.map{|a| build_zammad_attachment_filename(a)} - current_attachments.map{|a| a["filename"]}

            new_attachments = movidesk_attachments.select{|a| diff.include?(build_zammad_attachment_filename(a))}

            changed = new_attachments.size.positive?

            if changed
                result = current_attachments

                new_attachments.each do |new_attacment|
                    base64_content = download_attachement(new_attacment["path"])
                    result << {
                        filename: build_zammad_attachment_filename(new_attacment),
                        data: base64_content,
                        "mime-type": get_mimetype_from_filename(new_attacment["fileName"])
                    }
                end
            end
            
            [changed, result.nil? ? [] : result]
        end


        def create_ticket_in_zammad
            first_action = context.movidesk_ticket["actions"].first

            changed, attachments = build_attachments_array_from_movidesk_attachments(first_action["attachments"], [])
            
            ticket_params = {
                "#{context.movidesk_id_field_name}": context.movidesk_ticket_id,
                title: context.movidesk_ticket["subject"],
                customer_id: context.zammad_user_id,
                state_id: Zammad::Ticket.map_status(context.movidesk_ticket["status"]),
                group_id: context.group_id,
                note: "#{context.movidesk_id_field_name}:#{context.movidesk_ticket_id}",
                article: {
                    body: first_action.dig("htmlDescription"),
                    content_type: "text/html",
                    internal: first_action.dig("type") == 1,
                    # created_at: context.movidesk_ticket["createdDate"],
                    created_at: first_action["createdDate"],
                    type: first_action["type"] == 1 ? 'note' : 'email'
                },
                attachments: attachments,
                created_at: context.movidesk_ticket["createdDate"]
            }

            puts "Criando o ticket #{} no Zammad..."

            success, context.zammad_ticket = Zammad::Ticket.create(ticket_params)

            puts "Ticket MOVIDESK_ID: #{context.movidesk_ticket_id}, ZAMMAD_ID: #{context.zammad_ticket["id"]} criado  no Zammad com sucesso. Este ticket possui #{attachments.size} anexos" if success

            context.zammad_ticket_id = context.zammad_ticket["id"] if success

            context.fail!(message: "Não foi possível criar o ticket #{context.movidesk_ticket_id} no Zammad!!!!!!! TRACE: #{context.zammad_ticket.inspect}") unless success
        end

        def search_user_in_zammad(movidesk_user_id, email)
            puts "Pesquisando usuário no Zammad pelo movidesk_id..."

            success, result = Zammad::User.search("#{context.movidesk_id_field_name}:#{movidesk_user_id}")

            context.fail!(message: 'Não foi possível conectar a API do Zammad') unless success

            if result.size.positive?
                return result.first
            else
                puts "Pesquisando usuário no Zammad pelo e-mail..."

                email = fix_email(movidesk_user_id, email)
                success, result = Zammad::User.search("email:#{email}")

                context.fail!(message: 'Não foi possível conectar a API do Zammad') unless success

                if result.size.positive?
                    return result.first
                end
            end

            return false
        end
        

        def fix_email(movidesk_user_id, email)
            email.nil? ? "movidesk-cliente-importado-#{movidesk_user_id}@baladapp.com.br" : email
        end

        def create_user_in_zammad(movidesk_user_id,  movidesk_user_email, movidesk_user_name, created_at)

            # Se o usuário não possui e-mail um nome aleatório será gerado
            email = fix_email(movidesk_user_id, movidesk_user_email)

            user_params = {
                email: email,
                firstname: movidesk_user_name,
                "#{context.movidesk_id_field_name}": movidesk_user_id,
                created_at: created_at
            }

            puts "Criando a pessoa no Zammad..."
            
            success, result = Zammad::User.create(user_params)

            context.fail!(message: "Não foi possível criar o usuário #{movidesk_user_id} no Zammad! #{result.inspect}") unless success

            result
        end

        def search_ticket_in_zammad
            puts "Verificando se o ticket #{context.movidesk_ticket_id} já existe no Zammad..."

            success, result = Zammad::Ticket.search("#{context.movidesk_id_field_name}:#{context.movidesk_ticket_id}")

            context.fail!(message: 'Não foi possível conectar a API do Zammad') unless success

            context.ticket_exists = result.size.positive?

            context.zammad_ticket = result.first if context.ticket_exists
            context.zammad_ticket_id = result.first["id"] if context.ticket_exists
        end

        def fetch_movidesk_ticket_detail
            puts "Obtendo mais detalhes do ticket #{context.movidesk_ticket_id} no movidesk..."

            success, context.movidesk_ticket = Movidesk::Ticket.fetch_by_id(context.movidesk_ticket_id)

            context.fail!(message: "Não foi possível obter o ticket #{context.movidesk_ticket_id} no movidesk.") unless success
        end

        def validar_parametros
            context.fail!(message: "O parâmetro movidesk_ticket_id deve ser informado.") if context.movidesk_ticket_id.nil?
        end
    end
end