module JsonSchemaSpec
  class Tasks

    include Rake::DSL  if defined?(Rake::DSL)

    def initialize(url)
      return  unless defined?(Rake)

      namespace :spec do

        desc "Download JSON schema to `spec/fixtures`"
        task :schema do
          puts "\nDownloading JSON schema to `spec/fixtures`..."
          
          path = "#{Rake.original_dir}/spec/fixtures/schema.yml"
          JsonSchemaSpec.download(path, url)
          
          puts "Finished!\n\n"
        end
      end
    end
  end
end