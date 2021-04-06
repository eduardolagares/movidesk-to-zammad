#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'dotenv'

require 'interactor'

require './lib/movidesk/ticket.rb'
require './lib/movidesk/person.rb'
require './lib/zammad/ticket'
require './lib/zammad/ticket_article'
require './lib/zammad/ticket_state'
require './lib/zammad/object_attribute'
require './lib/zammad/user'
require './lib/zammad/import_tickets'
require './lib/zammad/import_ticket'
require 'faraday'
require 'json'
require 'pry'
require 'json'
require 'csv'
require 'benchmark'
require 'thread/pool'
require "down"
require "base64"
require 'mime/types'
require 'filemagic'



Dotenv.load

import "./lib/tasks/movidesk/export/peaple/to_json.rake"
import "./lib/tasks/movidesk/export/tickets/to_json.rake"
import "./lib/tasks/movidesk/export/export.rake"


import "./lib/tasks/zammad/import/tickets/from_json.rake"
import "./lib/tasks/zammad/import/import.rake"
import "./lib/tasks/zammad/create_custom_fields.rake"
import "./lib/tasks/zammad/create_ticket_custom_states.rake"
