require 'aws-sdk-s3'

class S3Mail
  def initialize(message_id)
    @message_id = message_id
    @body = read
  end

  def body
    @body
  end

  def read
    response = s3_client.get_object(
      bucket: Environment.bucket_name,
      key: object_key,
    )
    response.body.read()
  end

  def delete
    response = s3_client.delete_object(
        bucket: Environment.bucket_name,
        key: object_key,
    )
  end

  def object_key
    @object_key ||= "#{Environment.object_prefix}/#{@message_id}"
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(region: Environment.s3_region)
  end
end
