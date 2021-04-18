# frozen_string_literal: true

$DB.create_table? :majors do
  primary_key :pid
  String :major_id
  String :name
  String :college
  String :url
end

class Major < Sequel::Model
  def to_v1
    {
      major_id: pid,
      name: name,
      college: college,
      url: url
    }
  end

  def to_v0
    {
      major_id: major_id,
      name: name,
      college: college,
      url: url
    }
  end
end
