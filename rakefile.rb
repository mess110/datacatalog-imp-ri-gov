require File.dirname(__FILE__) + '/lib/puller'
require File.dirname(__FILE__) + '/lib/tasks'

def setup
  config_file = File.dirname(__FILE__) + '/config.yml'
  config = YAML.load_file(config_file)
  env = ENV['IMPORTER_ENV']
  raise "IMPORTER_ENV undefined" unless env
  raise "IMPORTER_ENV invalid" unless config[env]
  DataCatalog::Importer::Tasks.new({
    :api_key      => config[env]['api_key'],
    :base_uri     => config[env]['base_uri'],
    :cache_folder => '/cache/parsed',
    :name         => "District of Rhode Island Data Catalog",
    :uri          => "http://www.ri.gov/data/",
	:puller      =>  Puller
  })
end

setup
