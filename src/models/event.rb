class Event
  def initialize(event)
    @event = event
  end

  def message_id
    @event["Records"][0]["ses"]["mail"]["messageId"]
  end

  def source
    @event["Records"][0]["ses"]["mail"]["source"]
  end

  def destination
    @event["Records"][0]["ses"]["mail"]["destination"]
  end
end
