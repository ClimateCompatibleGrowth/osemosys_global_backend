module Ec2
  class UserData
    def initialize(run:)
      @run = run
    end

    def to_base64_encoded
      Base64.encode64(user_data)
    end

    private

    attr_reader :run

    def user_data
      <<~BASH
        #!/bin/bash
        su - ubuntu -c '#{solve_run_command}'
      BASH
    end

    def solve_run_command
      <<~BASH.squish
        cd /home/ubuntu/osemosys_global/
        && source /home/ubuntu/miniconda3/bin/activate osemosys-global
        && snakemake -c
      BASH
    end
  end
end
