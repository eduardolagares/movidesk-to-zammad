# Introdução

Conjunto de TASKS para efetuar a migração de dados do MOVIDESK para o ZAMMAD.


# ETAPAS

## EXPORTAÇÃO

### ETAPA 1

Faça uma cópia do arquivo .env.example par a.env e o preencha corretamente as variáveis do Movidesk.

### ETAPA 2

Faça a exportação dos dados do movidesk para os arquivos json

> bundle exec rake movidesk:export:tickets:to_json


## IMPORTAÇÃO

### ETAPA 1 - .env

Gere um tokem de acesso ao Zammad (http://localhost:8080/#profile/token_access) e cole ele na variável ZAMMAD_API_KEY do .env . Verifique também se a variável ZAMMAD_API_BASE_URL está configurada corretamente. 

Verifique se você configurou corretamente as variáveis do Zammad no arquivo .env 

### ETAPA 2 - Status customizados

Crie os status que existem no Movidesk mas não existem no Zammad. 

Obs: Você pode alterar essa task para gerar quantos status desejar.

> bundle exec rake zammad:create_ticket_custom_states

### ETAPA 3 - Mapeamento de status

Faça o mapeamento dos novos status no método Zammad::Ticket.map_status

### ETAPA 4 - Campos customizados

Crie os campos customizados necessários para a importação

> bundle exec rake zammad:create_custom_fields

Após criar os campos acesse seu zammad. Vá em config, objects e conceda as permissões de shown para os novos campos. Concluíndo clique no botão upgrade database e depois reinicie o Zammad.

Obs: Este passo cria os campos que serão utilizados para vincular ticket e clientes do zammad aos tickets e clientes do movidesk.

### ETAPA 5 - Colocando zammad em modo importação

Coloque o Zammad em modo de importação para respeitar as datas de criação dos tickets e clientes. 

Obs: Este comando deve ser executado no rails console do seu Zammad.

> Setting.set('import_mode', true)

Se vc está rodando com docker-compose, para iniciar o rails console execute:

> docker-compose exec zammad-railsserver rails c

### ETAPA 6 - Executando

Execute o comando a seguir para iniciar a importação dos tickets.

> bundle exec rake zammad:import:tickets:from_json start_page=1 total_pages=1 group_id=1

Parâmetros:

* start_page: Este é o número da página que deseja iniciar a importação, permitindo que vc comece ou retome a partir de uma página específica.
* total_pages: Total de páginas que serão processadas. Você pode colocar o número de arquivos json gerados na exportação
* group_id: Este é o id do grupo em que os usuários serão incluídos. Por padrão é o grupo default Users 1, mas você pode alterar.

Observações:

* Durante a importação do ticket o cliente também é importado.
* Caso o cliente não possua um e-mail válido, um e-mail é formado para ele combinad com o id no movidesk. Ex. movidesk-cliente-importado-123123123@baladapp.com.br"