class Environment
  def self.log_level
    @log_level ||= ENV["DEBUG_MODE"] == "1" ? :debug : :info
  end

  def self.bucket_name
    @bucket_name ||= ENV["BUCKET_NAME"]
  end

  def self.object_prefix
    @object_prefix ||= ENV["OBJECT_PREFIX"]
  end

  def self.s3_region
    @s3_region ||= ENV["S3_REGION"]
  end

  def self.forward_to
    @forward_to ||= ENV["FORWARD_TO"].split(",")
  end

  def self.transfer_from
    @transfer_from ||= ENV["TRANSFER_FROM"]
  end

  def self.developer_to
    @developer_to ||= ENV["DEVELOPER_TO"].split(",")
  end
end
