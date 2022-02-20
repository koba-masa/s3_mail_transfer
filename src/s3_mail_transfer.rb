require 'json'
require 'logger'

require './models/event'
require './models/forward_mail'
require './models/alarm_mail'

def lambda_handler(event:, context:)
  logger = Logger.new($stdout, level: Environment.log_level)
  logger.debug("Event = #{event}")

  custom_event = Event.new(event)

  ForwardMail.new(logger, custom_event).send

  logger.info("Success")
  { statusCode: 200, body: JSON.generate("Success") }
  rescue => e
    logger.info("Event = #{event}")
    logger.info("ErrorMessage = #{e.message}")
    logger.info("#{e.backtrace.join("\n")}")
    logger.error("Failed")
    AlarmMail.new(custom_event, e).send
    { statusCode: 500, body: JSON.generate("Faild") }
end
