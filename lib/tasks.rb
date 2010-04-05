module DataCatalog
	module Importer
		class Tasks

			def initialize(options)
				define(options)
			end

		protected

			def define(options)

				desc "Instructions for people to lazy to read info on github"
				task :default do
					puts "Instructions: "
					puts "Its easy.. First pull than push. Remember to declare IMPORTER_ENV"
					puts "Example pull: IMPORTER_ENV=local rake pull"
					puts "Example push: IMPORTER_ENV=local rake push"
				end

				desc "Pull data from the #{options[:name]}"
				task :pull do
					desc "Pull data from the #{options[:name]}"
					puller = Puller.new(options)
					puller.run
				end

				desc "Push data to the Data Catalog API"
				task :push do
					desc "Pushing data to the Data Catalog API..."
					raise "Not implemented yet!!!!!"
				end
			end

		end
	end
end
