require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class SourcePuller < Puller

	def initialize
		@parse_file	= Output.dir "/../cache/parsed/source"
		super
	end

	protected

	#[source.size, date_inserted, description, hostname, linkk, title, title_iwantto, updatedat, tags, org_title, site_category]
	def parse_metadata
		#now we need to parse each individual peace of data
		#ok now think. I don't have any direct xml link so I am actually gathering links that point to a website that points to usefull data
		@source.each do |data|
			timey = Time.parse(data[1])

			source = 
			{
				:catalog_name	=>	@catalog_name,
				:catalog_url	=>	@catalog_url, 
				:description	=>	data[2],
				#:downloads		=> "none",
				:frequency		=>	"unknown",
				:organization	=>	{
					:home_url	=>	data[3],
					:name		=>	data[9],
				},
				#:site_category =>	data[10], 	#optional
				:released		=>	{
					:day		=> timey.strftime("%d").to_i,
					:month		=> timey.strftime("%m").to_i,
					:year		=> timey.strftime("%Y").to_i,
				},
				#:updated		=>	data[7],	#optional
				:source_type	=>	"dataset",
				:title			=>	data[5],
				:url			=>	data[4],
				#:tags			=>	data[8],
			}
			if source[:organization][:name] == ""
				source[:organization][:name] = "District of Rhode Island"
			end
			if source[:title] == ""
				source[:title] = "Rhode Island Service"
			end

			yml_file = @parse_file + ("/%08i.yml" % (data[0].to_i + 1).to_s)
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
			U.write_yaml(yml_file, source) #erase this after
		end
	end

end
