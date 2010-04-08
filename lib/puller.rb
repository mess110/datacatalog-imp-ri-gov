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
		@source, @organization = get_metadata_data( document )
		parse_metadata
		return nil
	end

	protected

	def get_metadata_data ( doc )
		#create array with all the elements
		source = Array.new
		organization = Array.new

		doc.xpath('/hash/links/link').each do |link|

			#GET SOURCE DATA
			date_inserted = link.xpath('date-inserted').inner_text
			description = link.xpath('description').inner_text
			#hostname of the service
			hostname = link.xpath('hostname').inner_text
			#link of the service
			linkk = link.xpath('link').inner_text
			title = link.xpath('title').inner_text
			title_iwantto = link.xpath('title-iwantto').inner_text
			#last update
			updatedat = link.xpath('updated-at').inner_text
			#get tags
			tags = Array.new
			link.xpath('tags/tag').each do |tag|
				tags << tag.inner_text
			end

			#GET ORGANIZATION DATA
			site_category = link.xpath('hname/site-category').inner_text
			sos_entity_id = link.xpath('hname/sos-entity-id').inner_text
			org_title = link.xpath('hname/title')[0].inner_text rescue title = '' #since there are more thigns that start with title.. get the first one. if there is no first one than put default to ''
			title_abbrev = link.xpath('hname/title-abbrev').inner_text
			title_alpha = link.xpath('hname/title-alpha').inner_text


			#populate the collection
			source << [source.size, date_inserted, description, hostname, linkk, title, title_iwantto, updatedat, tags, org_title, site_category]

			#populate organizations
			#should I insert it? is it a duplicate?
			#gotta love ruby blocks <3
			insert = organization.find { |org| org[3] == org_title }
			organization << [organization.size, site_category, sos_entity_id, org_title, title_abbrev, title_alpha, hostname] if insert == nil
			
		end

		return source, organization
	end

end
