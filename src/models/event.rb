# https://docs.aws.amazon.com/ja_jp/ses/latest/dg/receiving-email-action-lambda-event.html

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

  def content_transfer_encoding
    @content_transfer_encoding ||= \
      headers.select { | header | header["name"] == "Content-Transfer-Encoding" }[0]["value"]
  end

  def content_type_mailtype
    @content_type_mailtype ||= /^(.*);.*/.match(content_type)[1]
  end

  def content_type_encoding
    @content_type_encoding ||= /.*charset=(.*)$/.match(content_type)[1]
  end

  def content_type
    @content_type ||= \
      headers.select { | header | header["name"] == "Content-Type" }[0]["value"]
  end

  def headers
    @event["Records"][0]["ses"]["mail"]["headers"]
  end
end
