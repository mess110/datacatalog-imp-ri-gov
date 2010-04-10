require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class SourcePuller < Puller

	def initialize
		@parse_file	= Output.dir "/../cache/parsed/source"
		super
	end

	protected

	def parse_metadata
		#now we need to parse each individual peace of data
		#ok now think. I don't have any direct xml link so I am actually gathering links that point to a website that points to usefull data
		@source.each do |data|
			#
			release_time = Time.parse(data[:date_inserted])

			source = 
			{
				:catalog_name	=>	@catalog_name,
				:catalog_url	=>	@catalog_url, 
				:description	=>	data[:description],
				:frequency		=>	"unknown",
				:organization	=>	{
					:home_url	=>	data[:hostname],
					:name		=>	data[:org_title],	#organization title
				},
				:released		=>	{
					:day		=> release_time.strftime("%d").to_i,
					:month		=> release_time.strftime("%m").to_i,
					:year		=> release_time.strftime("%Y").to_i,
				},
				:source_type	=>	"dataset",
				:title			=>	data[:title],
				:url			=>	data[:url],
			}

			if source[:organization][:name] == ""
				source[:organization][:name] = "District of Rhode Island"
			end

			if source[:title] == ""
				source[:title] = "Rhode Island Service"
			end

			#the file path which we are working on
			yml_file = @parse_file + ("/%08i.yml" % data[:id].to_s)
			#if the file was not saved before save it
			#if it was saved before and the saved timestamp is older than the new one, change it
			#caching is handled by last update :)
			begin
				back_then = Time.parse(YAML::load(File.open(yml_file))[:updated])
				right_now = Time.parse(data[:updated_at])
				if (back_then < right_now)
					U.write_yaml(yml_file, source)
				end
			end rescue U.write_yaml(yml_file, source)
			#TODO debugging purpose only
			U.write_yaml(yml_file, source) #erase this after
		end
	end

end
