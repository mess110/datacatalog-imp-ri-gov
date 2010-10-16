require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class OrganizationPuller < Puller

  def initialize
    @base_uri = 'http://www.ri.gov/links/?tags=online+service&ret=xml'
    @index_data     = Output.file '/../cache/raw/organization/index.yml'
    @index_html     = Output.file '/../cache/raw/organization/index.html'
    super
  end

  protected

  def get_metadata doc
    metadata = []
    doc.xpath('/hash/links/link/hname').each do |node|

      #in case the organization doesn't have a title, don't add it.
      title_org = node.xpath('title')[0].inner_text

      if title_org != ""
        metadata << {
          :site_category    => node.xpath('site-category').inner_text,
          :sos_entity_id    => node.xpath('sos-entity-id').inner_text,
          :title_abbrev     => node.xpath('title-abbrev').inner_text,
          :title_alpha      => node.xpath('title-alpha').inner_text,
          :title_org        => title_org
        }
      end
    end
    metadata
  end

  def parse_metadata
  end

end
