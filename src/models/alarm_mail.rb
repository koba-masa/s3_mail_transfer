require 'aws-sdk-ses'

require './models/environment'
require './models/event'

class AlarmMail
  def initialize(event, error)
    @event = event
    @error = error
  end

  def send
    ses_client.send_email(
      source: Environment.transfer_from,
      destination: {
        to_addresses: Environment.developer_to,
      },
      message: {
        body: {
          text: {
            charset: encoding,
            data: message,
          },
        },
        subject: {
          charset: encoding,
          data: subject,
        },
      },
    )
  end

  def message
    <<~"EOS"
      対象: #{Environment.object_prefix}
      メッセージID: #{event.message_id}
      エラーメッセージ: #{error.message}
    EOS
  end

  def subject
    "[#{Environment.object_prefix}]メール転送失敗"
  end

  def encoding
    'UTF-8'
  end

  def ses_client
    @ses_client ||= Aws::SES::Client.new
  end

  def event
    @event
  end

  def error
    @error
  end
end
