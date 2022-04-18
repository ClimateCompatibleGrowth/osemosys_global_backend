module Ec2
  class CreateInstance
    def self.call(...)
      new(...).call
    end

    def initialize(run: nil, disable_interconnector: false, instance_type: 't2.micro')
      @run = run
      @disable_interconnector = disable_interconnector
      @instance_type = instance_type
    end

    def call
      spawn_instance

      instance = Instance.create!(
        run: run,
        started_at: Time.current,
      )

      wait_until_running

      instance.update!(
        ip: spawned_instance.public_ip_address,
        instance_type: instance_type,
        aws_id: spawned_instance.id,
      )
    end

    private

    def instance_params
      InstanceParams.new(
        instance_type: instance_type,
        run: run,
        disable_interconnector: disable_interconnector,
      ).to_h
    end

    attr_reader :run, :instance_type, :disable_interconnector

    def spawn_instance
      @instances = resource.create_instances(instance_params)
    end

    def wait_until_running
      resource.client.wait_until(
        :instance_running, instance_ids: [@instances.first.id]
      )
    end

    def spawned_instance
      return unless @instances

      @_spawned_instance ||= @instances.first.load
    end

    def resource
      @_resource ||= Aws::EC2::Resource.new
    end
  end
end
