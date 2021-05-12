$DB.create_table? :buildings do
  Integer :id, primary_key: true
  String :name # Full building name
  String :code, unique: true, nullable: true # Building name, if applicable. E.G. "AVW"

  # Location and address data
  String :city
  String :state
  Integer :zip
  String :street       # Full address, e.g. 8125 Paint Branch Dr.
  String :street_name  # Just the street name, e.g. Paint Branch
  String :address_num  # Just the address number, e.g. 8125

  Float :long
  Float :lat
end

class Building < Sequel::Model
  def to_v0
    {
      name: name,
      code: code,
      id: id.to_s,
      lng: long.to_s,
      lat: lat.to_s
    }
  end

  def to_v1
    {
      name: name,
      code: code,
      id: id,
      city: city,
      state: state,
      zip: zip,
      street: street,
      street_name: street_name,
      address_num: address_num,
      long: long,
      lat: lat
    }
  end
end
