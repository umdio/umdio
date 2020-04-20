$DB.create_table? :buildings do
  primary_key :pid
  String :name
  String :code
  String :id
  Float :long
  Float :lat
end

class Building < Sequel::Model
  def to_v0
    {
      name: name,
      code: code,
      id: id,
      lng: long.to_s,
      lat: lat.to_s
    }
  end

  def to_v1
    {
      name: name,
      code: code,
      id: id,
      long: long,
      lat: lat
    }
  end
end