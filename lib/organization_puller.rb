require File.dirname(__FILE__) + '/puller'
require File.dirname(__FILE__) + '/output'

class OrganizationPuller < Puller

  def initialize
    @parse_file  = Output.dir "/../cache/parsed/organization"
    super
  end

  protected

  def parse_metadata
    #now we need to parse each individual peace of data
    #ok now think. I don't have any direct xml link so I am actually gathering links that point to a website that points to usefull data
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
        #the file path which we are working on
        yml_file = "%s/%08i.yml" % [@parse_file, data[:id]]
        #no timestamps here so caching is a little more primitive
        #write source if it is different from cached version

        U.write_yaml(yml_file, source) if U.fetch_yaml(yml_file) != source rescue U.write_yaml(yml_file, source)
      end
    end
  end

end
