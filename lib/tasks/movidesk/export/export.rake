namespace :movidesk do
    namespace :export do
        task :to_json do
            puts "### Iniciando a exportação de pessoas e tickets."
            Rake::Task['movidesk:export:peaple:to_json'].invoke
            Rake::Task['movidesk:export:tickets:to_json'].invoke
            puts "### Importação de pessoas concluída."
        end
    end
end