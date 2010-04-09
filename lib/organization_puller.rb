require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class OrganizationPuller < Puller

	def initialize
		@parse_file	= Output.dir "/../cache/parsed/organization"
		super
	end

	protected

	#[organization.size,s site_category, sos_entity_id, org_title, title_abbrev, title_alpha, hostname]
	def parse_metadata
		#now we need to parse each individual peace of data
		#ok now think. I don't have any direct xml link so I am actually gathering links that point to a website that points to usefull data
		@organization.each do |data|
			source = 
			{
				:organization => {
					:name => "District of Rhode Island"
				},
				:catalog_url => "http://ri.gov/data/agencies",
				:description => "Plans, develops, and implements the use of new technology for District agencies to improve delivery of services to residents, businesses and visitors.",
				:home_url => "http://" + data[6],
				:name => data[3],
				:org_type => "governmental",
				#:organization => {
				#	:name => "District of Rhode Island",
				#},
				:url => "http://" + data[6],
				#:active_organizations
				#:jurisditcions
			}

			if source[:name] != ""
			
#--- 
#:catalog_url: http://dc.gov/agencies
#:description: Offers comprehensive, integrated healthcare to medically underserved residents in Washington, DC.
#:home_url: http://www.greatersoutheast.org
#:name: Greater Southeast Community Hospital
#:org_type: governmental
#:organization: 
#  :name: District of Columbia
#:url: http://dc.gov/agencies/detail.asp?id=1030

			yml_file = @parse_file + ("/%08i.yml" % (data[0].to_i + 1).to_s)
			#no timestamps here so caching is a little more primitive
			#write source if it is different from cached version
			U.write_yaml(yml_file, source) if U.fetch_yaml(yml_file) != source rescue U.write_yaml(yml_file, source)
			end
		end
	end

end
