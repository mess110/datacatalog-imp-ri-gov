gem 'datacatalog-importer', '~> 0.1.19'
require 'datacatalog-importer'

class Puller

  U = DataCatalog::ImporterFramework::Utility
  I = DataCatalog::ImporterFramework

  FETCH_DELAY = 0.0
  FORCE_FETCH = true

  def initialize
    document = U.parse_xml_from_file_or_uri(@base_uri, @index_html,
      :force_fetch => FORCE_FETCH)
    @index_metadata = get_metadata(document)
    U.write_yaml(@index_data, @index_metadata)
  end

  def fetch
    nil
  end
end
