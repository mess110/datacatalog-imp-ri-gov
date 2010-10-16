require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class OrganizationPuller < Puller

  def initialize
    @index_data     = Output.file '/../cache/raw/organization/index.yml'
    @index_html     = Output.file '/../cache/raw/organization/index.html'
    super
  end

  protected

  def get_metadata doc
    metadata = []
    doc.xpath('/hash/links/link').each do |node|

      #in case the organization doesn't have a title, don't add it.
      title_org = node.xpath('hname/title')[0]
      begin
        title_org = title_org.inner_text
      rescue
        title_org = ""
      end

      # make sure the organization doesn't already exist or is null
      duplicates = metadata.select{ |h| h[:title_org] == title_org }

      if title_org != "" && duplicates.empty?
        metadata << {
          :site_category    => categorize_site(
                                  node.xpath('hname/site-category').inner_text),
          :sos_entity_id    => node.xpath('hname/sos-entity-id').inner_text,
          :title_abbrev     => node.xpath('hname/title-abbrev').inner_text,
          :title_alpha      => node.xpath('hname/title-alpha').inner_text,
          :hostname         => node.xpath('hostname').inner_text,
          :url              => URI.unescape(node.xpath('link').inner_text),
          :title_org        => title_org
        }
      end
    end
    metadata
  end

  def parse_metadata metadata
    {
      :name         => metadata[:title_org],
      :url          => metadata[:url],
      :home_url     => "http://" + metadata[:hostname],
      :catalog_name => "ri.gov",
      :catalog_url  => @base_uri,
      :org_type     => metadata[:site_category],
      :organization => {
        :name => "Rhode Island"
      }
    }
  end

  private

  # the 6 types accepted on ri.gov are G, M, Q, F, E, P and need to be
  # mapped to the database
  #
  # G Government    M Municipal                   Q Quasi-government
  # E Education     P Private (non-government)    F Federal
  def categorize_site cat
    governmental = ['G', 'M', 'Q', 'F']
    not_profit   = ['E']
    commercial   = ['P']
    if governmental.include?(cat)
      return "governmental"
    elsif not_profit.include?(cat)
      return "not-for-profit"
    end
    return "commercial"
  end

end
