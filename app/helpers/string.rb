class String
  def is_number?
    true if Float(self)
  rescue StandardError
    false
  end
end
