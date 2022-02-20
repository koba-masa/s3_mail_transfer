require 'logger'

require 'aws-sdk-s3'
require 'aws-sdk-ses'

require './models/environment'
require './models/event'

class ForwardMail

  def initialize(logger, event)
    @event = event
    @logger = logger
  end

  def send
    message = read_message
    message = edit_raw_message(message)
    @logger.debug("メッセージ内容:#{message}")
    ses_client.send_raw_email(
      {
        destinations: Environment.forward_to,
        source: Environment.transfer_from,
        raw_message: {
          data: message
        },
      }
    )
    delete_message
  end

  def edit_raw_message(message)
    # Return-Path と From の変更
    # https://docs.aws.amazon.com/ja_jp/ses/latest/dg/request-production-access.html
    processed_message = message \
      .gsub(/^Return-Path: .+?\r\n/, "Return-Path: #{Environment.transfer_from}\r\n") \
      .gsub(/\r\nFrom: .+?\r\n/, "\r\nFrom: #{Environment.transfer_from}\r\n")
    processed_message = processed_message.concat(
      "\r\n== ここまでが原文 ========\r\n本メールは転送されています。\r\n送信元メールアドレス: #{event.source}\r\n送信先メールアドレス: #{event.destination}\r\n"
    )
  end

  def read_message
    response = s3_client.get_object(
        bucket: Environment.bucket_name,
        key: message_key,
    )
    response.body.read()
  end

  def delete_message
    response = s3_client.delete_object(
        bucket: Environment.bucket_name,
        key: message_key,
    )
  end

  def ses_client
    @ses_client ||= Aws::SES::Client.new
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: Environment.s3_region)
  end

  def message_key
    @message_key ||= "#{Environment.object_prefix}/#{event.message_id}"
  end

  def event
    @event
  end
end
