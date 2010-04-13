require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class OrganizationPuller < Puller

  def initialize
    @parse_file  = Output.dir "/../cache/parsed/organization"
    super
  end

  protected

  def parse_metadata
    @organization.each do |data|
      source = 
      {
        :organization  => { :name => "District of Rhode Island" },
        :catalog_url   => "http://ri.gov/data/agencies",
        :description   => "",
        :home_url      => "http://" + data[:hostname],
        :name          => data[:org_title],
        :org_type      => "governmental",
        :url           => "http://" + data[:hostname],
      }

      #don't upload organizations that don't have a name
      if source[:name] != ""
        yml_file = "%s/%08i.yml" % [@parse_file, data[:id]]
        #no timestamps here so caching is a little more primitive
        #write source if it is different from cached version
        if U.fetch_yaml(yml_file) != source 
		U.write_yaml(yml_file, source)
	end rescue U.write_yaml(yml_file, source)
      end
    end
  end

end
