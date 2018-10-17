require 'logger'

module ScraperCommon
    def logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
            date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
            "[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
        end
        @logger
    end

    def database(table)
        host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
        port = ENV['MONGO_RUBY_DRIVER_PORT'] || Mongo::DEFAULT_PORT

        self.logger.info "Connecting to #{host}:#{port}"
        db = Mongo::MongoClient.new(host, port, pool_size: 2, pool_timeout: 2).db(table)
    end
end
