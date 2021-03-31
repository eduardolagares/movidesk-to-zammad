namespace :zammad do
    namespace :import do
        task :from_json do
            Rake::Task['zammad:import:peaple:from_json'].invoke([ENV["start_page"], ENV["total_pages"]])
            Rake::Task['zammad:import:tickets:from_json'].invoke([ENV["start_page"], ENV["total_pages"]])
        end
    end
end