require 'logger'
require 'sequel'

module ScraperCommon
    # TODO: Load config from memory
    $DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')

    def logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
            date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
            "[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
        end
        @logger
    end

    #TODO: Deprecated. Use sequel instead
    def database(table)
        host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
        port = ENV['MONGO_RUBY_DRIVER_PORT'] || Mongo::DEFAULT_PORT

        self.logger.info "Connecting to #{host}:#{port}"
        db = Mongo::MongoClient.new(host, port, pool_size: 2, pool_timeout: 2).db(table)
    end

    #TODO: Deprecated. Use sequel instead
    def postgres
        db = PG.connect(
            dbname: 'umdio',
            host: 'postgres',
            port: '5432',
            user: 'postgres'
        )

        # Setup generic tables
        sql = File.open(File.join(File.dirname(__FILE__), '/sql/courses.sql'), 'rb') { |file| file.read }
        db.exec(sql)

        return db
    end

    # Takes in a list of years and semesters. It maps years to 4 semesters, and semesters to themselves
    # 2018 -> 201801, 201805, 201808, 201812
    # 201901 -> 201901
    def get_semesters(args)
        semesters = args.map do |e|
            if e.length == 6
                e
            else
                [e + '01', e + '05', e + '08', e + '12']
            end
        end
        semesters.flatten
    end
end
