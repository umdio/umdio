require 'logger'
require 'sequel'

module ScraperCommon
    # TODO: Load config from memory
    $DB = Sequel.connect('postgres://postgres@postgres:5432/umdio')
    $DB.extension :pg_array, :pg_json

    def logger
        @logger = Logger.new(STDOUT)
        @logger.level = Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
            date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
            "[#{date_format}] #{severity}  (#{progname}): #{msg}\n"
        end
        @logger
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
