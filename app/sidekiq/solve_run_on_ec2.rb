class SolveRunOnEc2
  INSTANCE_TYPE = 'r6i.xlarge'.freeze
  include Sidekiq::Job

  def perform(run_id)
    return unless enabled?

    run = Run.find(run_id)
    run.ongoing!
    Ec2::CreateInstance.call(run: run, disable_interconnector: true, instance_type: INSTANCE_TYPE)
    Ec2::CreateInstance.call(run: run, disable_interconnector: false, instance_type: INSTANCE_TYPE)
  end

  private

  def enabled?
    ENV['SOLVE_RUN_ON_EC2'] == 'true'
  end
end
