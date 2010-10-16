require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class SourcePuller < Puller

  def initialize
    @base_uri = 'http://www.ri.gov/links/?tags=online+service&ret=xml'
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

      metadata << {
        # there are like 4-5 orgs. is this worth it?
        #:date_inserted    =>  node.xpath('date-inserted').inner_text,
        :description      =>  node.xpath('description').inner_text,
        :hostname         =>  node.xpath('hostname').inner_text,
        :url              =>  node.xpath('link').inner_text,
        :title            =>  node.xpath('title').inner_text,
        #short title to describe what the service does
        #ex: <title-iwantto>renew my car insurance</title-iwantto>
        :title_i_want_to  =>  node.xpath('title-iwantto').inner_text,
        :updated_at       =>  node.xpath('updated-at').inner_text,
        :tags             =>  tags
      }
    end
    metadata
  end

  def parse_metadata
  end

end
