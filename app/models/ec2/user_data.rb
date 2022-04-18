module Ec2
  class UserData
    SCRIPT_URL = 'https://osemosys-global-backend.herokuapp.com/run_workflow.sh'.freeze

    def initialize(run:, disable_interconnector: false)
      @run = run
      @disable_interconnector = disable_interconnector
    end

    def to_base64_encoded
      Base64.encode64(user_data)
    end

    private

    attr_reader :run, :disable_interconnector

    def user_data
      <<~BASH
        #!/bin/bash
        set -e

        terminate_instance() {
          echo "Terminating instance now..."
          #{'sudo shutdown -h now' if shutdown_on_finish?}
        }

        trap "terminate_instance" ERR

        snap install yq
        su - ubuntu -c '#{solve_run_command}'

        terminate_instance
      BASH
    end

    def solve_run_command
      <<~BASH.squish
        curl #{SCRIPT_URL} | bash -s -- "#{config_file_url}"
      BASH
    end

    def config_file_url
      if Rails.env.development?
        'https://osemosys-global-backend.herokuapp.com/config.yaml'
      else
        "https://osemosys-global-backend.herokuapp.com/runs/#{run.slug}.yml?disable_interconnector=#{disable_interconnector}"
      end
    end

    def shutdown_on_finish?
      ENV['DISABLE_SHUTDOWN_ON_FINISH'] != 'true'
    end
  end
end
