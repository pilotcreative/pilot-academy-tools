module Configuration
  class << self
    attr_reader :logger
  end

  def logger
    Configuration.logger
  end

  def configuration
    Configuration.configuration
  end

  def self.configuration
    Configuration.configure_logger
    # ...
  end

  private

  def self.configure_logger
    @logger = Logger.new($stdout)
    @logger.progname = Constants::APP_NAME
    @logger.formatter = proc do |severity, _datetime, progname, msg|
      "#{progname} #{severity}: #{msg}\n"
    end
  end
end
