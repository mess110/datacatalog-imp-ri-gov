gem 'datacatalog-importer', '~> 0.1.19'
require 'datacatalog-importer'
require 'uri'

class Puller

  U = DataCatalog::ImporterFramework::Utility
  I = DataCatalog::ImporterFramework

  FETCH_DELAY = 0.0
  FORCE_FETCH = true

  def initialize
    @base_uri = 'http://www.ri.gov/links/?tags=online+service&ret=xml'
    document = U.parse_xml_from_file_or_uri(@base_uri, @index_html,
      :force_fetch => FORCE_FETCH)
    @index_metadata = get_metadata(document)
    U.write_yaml(@index_data, @index_metadata)
  end

  def fetch
    sleep(FETCH_DELAY)
    data_from_index_page = @index_metadata.pop
    if data_from_index_page
      return parse_metadata(data_from_index_page)
    end
    nil
  end
end
