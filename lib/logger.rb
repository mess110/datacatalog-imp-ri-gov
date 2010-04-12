class Logger

  attr_accessor :filename
  
  def initialize(filename)
    self.filename = filename
    log = read
    @log = log.is_a?(Hash) ? log : {}
    true
  end

  def read
    return nil unless File.exist?(filename)
    YAML::load_file(filename)
  end
  
  def update(uid, payload)
    @log[uid] = {} unless @log[uid]
    @log[uid] = payload
    true
  end
  
  def write
    DataCatalog::Utility.write_yaml(filename, @log)
    true
  end

end
