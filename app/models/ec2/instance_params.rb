module Ec2
  class InstanceParams
    def initialize(instance_type:, run:)
      @instance_type = instance_type
      @run = run
    end

    def to_h
      {
        image_id: 'ami-098288cdf25d9bcc9', # osemosys_global_v1
        min_count: 1,
        max_count: 1,
        key_name: 'yboulkaid-osemosys',
        user_data: encoded_user_data,
        security_group_ids: ['sg-43911f25'],
        instance_type: instance_type,
        iam_instance_profile: {
          name: 'OsemosysGlobalEC2Role',
        },
        instance_initiated_shutdown_behavior: 'terminate',
      }
    end

    private

    attr_reader :instance_type, :run

    def encoded_user_data
      UserData.new(run: run).to_base64_encoded
    end
  end
end
