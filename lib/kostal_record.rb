class KostalRecord
  def initialize(id, payload)
    @id = id
    @payload = payload
  end

  attr_reader :id

  def to_hash
    @payload
  end

  def measure_time
    @payload[:measure_time]
  end
end
