#
# Copyright (c) 2015 Sam4Mobile
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Monkey patch RunAction to create a suites scheduler that consider
# - each suite is a different node
# - some suites must converge first

require 'kitchen/command'

module Kitchen
  module Command

    module RunAction
      alias_method :run_action_official, :run_action

      def run_action(action, instances, *args)
        # Define suites as global so we can use them to generates nodes
        # in CommonSandbox
        $suites = @config.send(:data).suite_data

        # Extract helper instance(s) to be able to launch it first
        # so it is ready for other containers
        helpers = instances.select do |i|
          (i.suite.name.include? "server")
        end
        services = instances - helpers

        case action
        when :destroy
          run_action_official(action, instances, *args)
        when :test
          run_action_official(:destroy, instances)
          run_converge(instances, services, helpers)
          run_action_official(:verify, instances)
          run_action_official(:destroy, instances) if args.first == :passing
        when :create
          run_create(instances, services, helpers)
        when :converge
          run_converge(instances, services, helpers)
        else
          run_converge(instances, services, helpers) if action == :verify
          run_action_official(action, instances, *args) if action != :create
        end
      end

      def run_create(instances, services, helpers)
        run_action_official(:create, helper)
        run_action_official(:create, services)
      end

      def run_converge(instances, services, helpers)
        run_action_official(:converge, helpers)
        run_action_official(:converge, services)
      end

    end

  end
end
