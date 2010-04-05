require 'open-uri'
require 'nokogiri'


require File.dirname(__FILE__) + '/output'
require File.dirname(__FILE__) + '/utility'

class Puller

	U = DataCatalog::Utility
	REQUIRED = %w(cache_folder name uri puller)        

	FORCE_FETCH = false # true

	def initialize(options)
		REQUIRED.each do |r|
			raise "option :#{r} is required" unless options[r.intern]
        end
		#the options. this is a really desciptive comment!
		@options			=	options
		@base_uri			=	'http://www.ri.gov/links/?tags=online+service&ret=xml'
		@parse_source		=	Output.dir "/../#{@options[:cache_folder]}/source"
		@parse_organization	=	Output.dir "/../#{@options[:cache_folder]}/organization"
	    #@index_data			=	Output.file '/../cache/raw/index.yml'
	    @index_xml			=	Output.file '/../cache/raw/index.xml'
		@pull_log       	=	Output.file '/../cache/raw/pull_log.yml'
	end

	def run
		#report timing for this task
		U.report_timing "pull and parse xml" do
			doc = U.parse_xml_from_file_or_uri(@base_uri, @index_xml, :force_fetch => FORCE_FETCH)
			collection, organization = get_catalog_data(doc)
			parse_source(collection)
			parse_organization(organization)
			#write the raw index data in /cache/raw/index.xml
			#U.write_yaml(@index_data, metadata)
		end
	end

	private

	def get_catalog_data ( doc )
		#create array with all the elements
		collection = Array.new
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
			collection << [collection.size, date_inserted, description, hostname, linkk, title, title_iwantto, updatedat, tags, org_title, site_category]

			#populate organizations
			#should I insert it? is it a duplicate?
			#gotta love ruby blocks <3
			insert = organization.find { |org| org[3] == org_title }
			organization << [organization.size, site_category, sos_entity_id, org_title, title_abbrev, title_alpha] if insert == nil
			
		end

		return collection, organization
	end

	def parse_organization( metadata )
				#now we need to parse each individual peace of data
		#ok now think. I don't have any direct xml link so I am actually gathering links that point to a website that points to usefull data
		metadata.each do |data|
			source = 
			{
				:catalog		=>	{
					:name		=>	@options[:name],
					:url		=>	@options[:uri],
				},
				:sos_entity_id	=>	data[2],
				:organization	=>	{
					:title		=>	data[3],
					:title_abbrev	=>	data[4],
					:title_alpha	=> data[5],
				},
				:site_category	=>	data[1],
			}

			yml_file = @parse_organization + ("/%08i.yml" % data[0])
			#no timestamps here so caching is a little more primitive
			#write source if it is different from cached version
			U.write_yaml(yml_file, source) if U.fetch_yaml(yml_file) != source rescue U.write_yaml(yml_file, source)
		end
	end

	def parse_source( metadata )
		#now we need to parse each individual peace of data
		#ok now think. I don't have any direct xml link so I am actually gathering links that point to a website that points to usefull data
		metadata.each do |data|
			source = 
			{
				:catalog_name	=>	@options[:name],
				:catalog_url	=>	@options[:uri],
				:description	=>	data[2],
				:frequency		=>	"unknown",
				:organization	=>	{
					:home_url	=>	data[3],
					:name		=>	data[9],
					:site_category =>	data[10],
				},
				:released		=>	data[1],
				:updated		=>	data[7],
				:source_type	=>	"dataset",
				:title			=>	{
					:title		=>	data[5],
					:title_iwantto	=> data[6],
				},
				:url			=>	data[4],
				:tags			=>	data[8],
			}

			yml_file = @parse_source + ("/%08i.yml" % data[0])
			#if the file was not saved before save it
			#if it was saved before and the saved timestamp is older than the new one, change it
			#caching is handled by last update :)
			begin
				backthen = Time.parse(YAML::load(File.open(yml_file))[:updated])
				rightnow = Time.parse(data[7])
				if (backthen < rightnow)
					U.write_yaml(yml_file, source)
				end
			end rescue U.write_yaml(yml_file, source)
		end
	end

end
