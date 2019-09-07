$DB.drop_table? :routes
$DB.create_table? :routes do
    primary_key :pid
    String :route_id
    String :title
    Float :lat_max
    Float :lat_min
    Float :long_max
    Float :long_min
    column :stops, :jsonb
    column :directions, :jsonb
    column :paths, :jsonb
end

$DB.drop_table? :stops
$DB.create_table? :stops do
    primary_key :pid
    String :stop_id
    String :title
    Float :long
    Float :lat
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
