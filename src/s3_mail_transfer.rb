require 'json'
require 'logger'

require 'aws-sdk-ses'

require './src/models/environment'
require './src/models/event'
require './src/models/s3_mail'
require './src/models/alarm_mail'

def lambda_handler(event:, context:)
  logger.debug("Event: #{event}")
  @custom_event = Event.new(event)

  s3_mail = S3Mail.new(custom_event.message_id)
  logger.debug("Original Raw Email: #{s3_mail.body}")

  edited_raw_mail = edit_raw_mail(s3_mail)
  logger.debug("Edited Raw Email: #{edited_raw_mail}")

  send_mail(edited_raw_mail)

  # 想定しているのはtext/plainなメールそれ以外の場合は、念の為、アラームメールを送信し、メッセージ削除を行わない
  if custom_event.content_type_mailtype == "text/plain"
    original_mail.delete
  else
    error_message = "This mail is not text/plain.: #{custom_event.content_type_mailtype}"
    logger.warn(error_message)
    raise error_message
  end

  logger.info("Success")
  { statusCode: 200, body: JSON.generate("Success") }
rescue => e
  logger.info("Event: #{event}")
  logger.info("ErrorMessage: #{e.message}")
  logger.info("#{e.backtrace.join("\n")}")
  logger.error("Failed")
  AlarmMail.new(custom_event, e).send
  { statusCode: 500, body: JSON.generate("Faild") }
end

def edit_raw_mail(original_mail)
  original_raw_mail = original_mail.body

  # Return-Path と From の変更
  # https://docs.aws.amazon.com/ja_jp/ses/latest/dg/request-production-access.html
  edited_raw_mail = original_raw_mail \
    .gsub(/^Return-Path: .+?\r\n/, "Return-Path: #{Environment.transfer_from}\r\n") \
    .gsub(/\r\nReturn-Path: .+?\r\n/, "Return-Path: #{Environment.transfer_from}\r\n") \
    .gsub(/^From: .+?\r\n/, "From: #{Environment.transfer_from}\r\n") \
    .gsub(/\r\nFrom: .+?\r\n/, "\r\nFrom: #{Environment.transfer_from}\r\n")
  

  add_message = "\r\n== This is the original text. ========\r\nThis mail was transfered.\r\nOriginal From MailAddress: #{custom_event.source}\r\nOriginal To MailAddress: #{custom_event.destination}\r\n" \
    .encode(custom_event.content_type_encoding)

  edited_raw_mail.concat(add_message)
end

def send_mail(raw_mail)
  logger.debug("メッセージ内容:#{raw_mail}")
  ses_client.send_raw_email(
    {
      destinations: Environment.forward_to,
      source: Environment.transfer_from,
      raw_message: {
        data: raw_mail
      },
    }
  )
end

def custom_event
  @custom_event
end

def ses_client
  @ses_client ||= Aws::SES::Client.new
end

def logger
  @logger ||= Logger.new($stdout, level: Environment.log_level)
end
