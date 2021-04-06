namespace :zammad do
    namespace :import do
        task :from_json do
            Rake::Task['zammad:import:tickets:from_json'].invoke([ENV["start_page"], ENV["total_pages"], ENV["group_id"], ENV["start_index"]])
        end
    end
end