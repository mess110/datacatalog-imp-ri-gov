require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class SourcePuller < Puller

  def initialize
    @index_data     = Output.file '/../cache/raw/source/index.yml'
    @index_html     = Output.file '/../cache/raw/source/index.html'
    super
  end

  protected

  def get_metadata doc
    metadata = []
    doc.xpath('/hash/links/link').each do |node|

      tags = []
      node.xpath('tags/tag').each do |tag|
       tags << tag.inner_text
      end

      title_org = node.xpath('hname/title')[0]
      begin
        title_org = title_org.inner_text
        if title_org == ""
          title_org = "Rhode Island"
        end
      rescue
        title_org = "Rhode Island"
      end

      metadata << {
        :date_inserted    => node.xpath('date-inserted').inner_text,
        :description      => U.multi_line_clean(
                                node.xpath('description').inner_text),
        :hostname         => "http://" + node.xpath('hostname').inner_text,
        :url              => URI.unescape(node.xpath('link').inner_text),
        :title            => node.xpath('title').inner_text,
        #short title to describe what the service does
        #ex: <title-iwantto>renew my car insurance</title-iwantto>
        :title_i_want_to  => node.xpath('title-iwantto').inner_text,
        :updated_at       => node.xpath('updated-at').inner_text,
        :title_org        => title_org,
        :tags             => tags
      }
    end
    metadata
  end

  def parse_metadata metadata
    {
      :title        => metadata[:title],
      :description  => metadata[:description],
      :frequency    => "unknown",
      :source_type  => "dataset",
      :catalog_name => "ri.gov",
      :downloads    => [],
      :catalog_url  => @base_uri,
      :url          => metadata[:url],
      :organization => {
        :url  => metadata[:hostname],
        :name => metadata[:title_org]
      }
    }
  end

end
