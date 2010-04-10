gem 'datacatalog-importer', '>= 0.1.11'
require 'datacatalog-importer'

class Puller

  U = DataCatalog::Utility
  I = DataCatalog::Importer
  
  FETCH_DELAY = 0.0 # 0.1 seconds
  FORCE_FETCH = false # true

	def initialize
		@catalog_name = "District of Rhode Island Data Catalog"
		@catalog_url = "http://ri.gov/data"
		@base_uri = "http://www.ri.gov/links/?tags=online+service&ret=xml"
		@index_xml = Output.file "/../cache/raw/index.xml"
	end

	def fetch
		sleep(FETCH_DELAY)
		document = U.parse_xml_from_file_or_uri(@base_uri, @index_xml, :force_fetch => FORCE_FETCH)
		@source, @organization = get_metadata( document )
		parse_metadata
		return nil
	end

	protected

	def get_metadata ( doc )
		#create array with all the elements
		source = []
		organization = []

		doc.xpath('/hash/links/link').each do |node|

			#GET SOURCE DATA
			date_inserted		=	node.xpath('date-inserted').inner_text
			description			= node.xpath('description').inner_text
			hostname				= node.xpath('hostname').inner_text
			url							= node.xpath('link').inner_text
			title						= node.xpath('title').inner_text
			#title_i_want_to
			title_i_want_to = node.xpath('title-iwantto').inner_text
			updated_at				= node.xpath('updated-at').inner_text
			#get tags
			tags = []
			node.xpath('tags/tag').each do |tag|
				tags << tag.inner_text
			end

			#GET ORGANIZATION DATA
			site_category		= node.xpath('hname/site-category').inner_text
			sos_entity_id		= node.xpath('hname/sos-entity-id').inner_text
			#since there are more things that start with title.. get the
			#first one. If there is no first one, assign title = ''
			org_title				= node.xpath('hname/title')[0].inner_text rescue title = ''
			title_abbrev		= node.xpath('hname/title-abbrev').inner_text
			title_alpha			= node.xpath('hname/title-alpha').inner_text

			#fix malformed formats
			#hostname has to begin with http://
			  #include UrlValidator
  			#validate hostname

			#populate the collection
			foo = {
				:id								=>	source.size + 1,
				:date_inserted		=>	date_inserted,
				:description			=>	description,
				:hostname					=>	hostname,
				:url							=>	url,
				:title						=>	title,
				#short phrase to describe what the service does
				#ex: <title-iwantto>renew my car insurance</title-iwantto>
				:title_i_want_to	=>	title_i_want_to,
				:updated_at				=>	updated_at,
				:tags							=>	tags,
				:org_title				=>	org_title,
				:site_category		=>	site_category,
			}

			source << foo

			#populate organizations
			#should I insert it? is it a duplicate?
			#gotta love ruby blocks <3
			insert = organization.find { |org| org[:org_title] == org_title }
			#foo = nil
			foo = {
				:id								=>	organization.size + 1,
				:site_category		=>	site_category,
				:sos_entity_id		=>	sos_entity_id,
				:org_title				=>	org_title,
				:title_abbrev			=>	title_abbrev,
				:title_alpha			=>	title_alpha,
				:hostname					=>	hostname,
			}
			organization << foo if insert == nil
			
		end
		[source, organization]
	end

end
