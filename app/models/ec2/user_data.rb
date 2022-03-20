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
        set -e

        terminate_instance() {
          # Uncomment when going live
          # sudo shutdown -h now
        }

        trap "terminate_instance" ERR

        su - ubuntu -c '#{solve_run_command}'

        terminate_instance
      BASH
    end

    def solve_run_command
      <<~BASH.squish
        cd /home/ubuntu/osemosys_global/
        && wget --output-document=/home/ubuntu/osemosys_global/config/config.yaml #{config_file_url}
        && source /home/ubuntu/miniconda3/bin/activate osemosys-global
        && snakemake -c
      BASH
    end

    def config_file_url
      if Rails.env.development?
        'https://osemosys-global-backend.herokuapp.com/config.yaml'
      else
        "https://osemosys-global-backend.herokuapp.com/runs/#{run.id}.yml"
      end
    end
  end
end
