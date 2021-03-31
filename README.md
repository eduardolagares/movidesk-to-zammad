# Introdução

Conjunto de TASKS para efetuar a migração de dados do MOVIDESK para o ZAMMAD.

# MOVIDESK

## Export

> bundle exec rake movidesk:export:to_json
> bundle exec rake movidesk:export:peaple:to_json
> bundle exec rake movidesk:export:tickets:to_json


# ZAMMAD

Siga os seguintes passos para efetuar a migração:

## Verifique se você precisa criar algum status novo, se sim, o código abaixo auxilia na criação dentro do rails console

> Ticket::State.create!(name: 'Canceled', state_type_id: 5, updated_by_id: 1, created_by_id: 1)

## Mapear status

Faça o mapeamento dos status novos no método Zammad::Ticket.map_status

## Crie os seguintes campos customizados

> Objetos -> Chamado > movidesk_ticket_identificador (integer (maximal 10000000000000000))
> Objetos -> Usuario > identificador_movidesk (integer (maximal 10000000000000000))

## Importação

Importação total

> bundle exec rake movidesk:import:from_json

Importação de pessoas

> bundle exec rake movidesk:import:peaple:from_json

Importação de tickets

> bundle exec rake movidesk:import:tickets:from_json