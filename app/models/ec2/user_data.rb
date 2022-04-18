module Ec2
  class UserData
    SCRIPT_URL = 'https://osemosys-global-backend.herokuapp.com/run_workflow.sh'.freeze

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
          echo "Shutting down now"
          # sudo shutdown -h now
        }

        trap "terminate_instance" ERR

        su - ubuntu -c '#{solve_run_command}'

        terminate_instance
      BASH
    end

    def solve_run_command
      <<~BASH.squish
        curl #{SCRIPT_URL} | bash -s -- #{config_file_url}
      BASH
    end

    def config_file_url
      if Rails.env.development?
        'https://osemosys-global-backend.herokuapp.com/config.yaml'
      else
        "https://osemosys-global-backend.herokuapp.com/runs/#{run.slug}.yml"
      end
    end
  end
end
