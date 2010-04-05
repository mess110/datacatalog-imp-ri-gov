module DataCatalog
	class Utility
		def self.write_yaml(f, data)
			File.open(f, "w") do |d|
				YAML::dump(data, d)
			end
		end

		def self.fetch_yaml(f)
			return YAML::load(File.open(f, "r"))
		end

		def self.parse_xml_from_file(filename)
			return Nokogiri::XML(File.open(filename))
		end

		def self.parse_xml_from_uri(uri)
			puts "Fetching #{uri}..."
			return Nokogiri::XML(open(uri))
    	end
    
		def self.parse_xml_from_file_or_uri(uri, file, options={})
			if options[:force_fetch] || !File.exist?(file)
				doc = parse_xml_from_uri(uri)
				File.open(file, "w") { |f| f.write(doc) }
			end
			doc = parse_xml_from_file(file) #keep parsing it because of note 01. didn't have time to check it yet
			return doc
    	end

		def self.report_timing(label)
			puts "Starting: [#{label}]"
			t0 = Time.now
			result = yield
			t1 = Time.now
			diff = t1 - t0
			puts "Elapsed time [#{label}] %.2f s" % diff
			result
		end
	end
end

