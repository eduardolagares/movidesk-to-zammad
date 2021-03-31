#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'dotenv'
require './lib/movidesk/ticket.rb'
require './lib/movidesk/person.rb'
require './lib/zammad/ticket'
require './lib/zammad/user'
require 'faraday'
require 'json'
require 'pry'
require 'json'
require 'CSV'

Dotenv.load

import "./lib/tasks/movidesk/export/peaple/to_json.rake"
import "./lib/tasks/movidesk/export/tickets/to_json.rake"
import "./lib/tasks/movidesk/export/export.rake"


import "./lib/tasks/zammad/import/peaple/from_json.rake"
import "./lib/tasks/zammad/import/tickets/from_json.rake"
import "./lib/tasks/zammad/import/import.rake"
