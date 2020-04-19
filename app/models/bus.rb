# TODO: None of this is actually "relational". Really, all we've done here is define a schema.

$DB.create_table? :routes do
    primary_key :pid
    String :route_id, {unique: true}
    String :title
    Float :lat_max
    Float :lat_min
    Float :long_max
    Float :long_min
    column :stops, :jsonb
    column :directions, :jsonb
    column :paths, :jsonb
end

$DB.create_table? :stops do
    primary_key :pid
    String :stop_id, {unique: true}
    String :title
    Float :long
    Float :lat
end

$DB.create_table? :schedules do
    String :route
    String :days
    String :direction
    String :schedule_class
    column :stops, :jsonb
    column :trips, :jsonb
end

class Route < Sequel::Model
    def to_v1
        p = paths.map do |path|
            x = path.map do |pp|
                pp['long'] = pp['lon'].to_f
                pp.delete 'lon'

                pp['lat'] = pp['lat'].to_f

                pp
            end
        end

        {
            route_id: route_id,
            title: title,
            lat_max: lat_max,
            lat_min: lat_min,
            long_max: long_max,
            long_min: long_min,
            stops: stops,
            directions: directions,
            paths: paths
        }
    end

    def to_v1_info
        {
            route_id: route_id,
            title: title,
        }
    end

    def to_v0
        {
            route_id: route_id,
            title: title,
            lat_max: lat_max.to_s,
            lat_min: lat_min.to_s,
            lon_max: long_max.to_s,
            lon_min: long_min.to_s,
            stops: stops,
            directions: directions,
            paths: paths
        }
    end

    def to_v0_info
        {
            route_id: route_id,
            title: title,
        }
    end
end

class Stop < Sequel::Model
    def to_v1_info
        {
            stop_id: stop_id,
            title: title
        }
    end

    def to_v1
        {
            stop_id: stop_id,
            title: title,
            lat: lat,
            long: long
        }
    end

    def to_v0_info
        {
            stop_id: stop_id,
            title: title
        }
    end

    def to_v0
        {
            stop_id: stop_id,
            title: title,
            lat: lat.to_s,
            lon: long.to_s
        }
    end
end

class Schedule < Sequel::Model
    def to_v1
        {
            route: route,
            days: days,
            direction: direction,
            stops: stops,
            trips: trips
        }
    end

    def to_v0
        {
            route: route,
            days: days,
            direction: direction,
            stops: stops,
            trips: trips
        }
    end
end