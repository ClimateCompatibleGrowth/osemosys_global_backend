class SolveRunOnEc2
  include Sidekiq::Job

  def perform(run_id)
    return unless enabled?

    run = Run.find(run_id)
    Ec2::CreateInstance.call(run: run, instance_type: 'c6i.large')
  end

  private

  def enabled?
    ENV['SOLVE_RUN_ON_EC2'] == 'true'
  end
end
