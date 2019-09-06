$DB.create_table? :routes do
    primary_key :pid
    String :route_id
    String :title
    Float :lat_max
    Float :lat_min
    Float :lon_max
    Float :lon_min
end

$DB.create_table? :stops do
    primary_key :pid
    String :stop_id
    String :title
    Float :long
    Float :lat
end

$DB.create_table? :directions do
    primary_key :pid
    String :direction_id
    String :title
end

$DB.create_table? :points do
    primary_key :pid
    Float :lat
    Float :long
end

$DB.create_table? :paths do
    primary_key :pid
end

class Route < Sequel::Model
    def to_v0_info
        {
            route_id: route_id,
            title: title,
        }
    end
end

class Stop < Sequel::Model

end

class Direction < Sequel::Model

end

class Point < Sequel::Model

end

class Path < Sequel::Model

end