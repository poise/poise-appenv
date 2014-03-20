#
# Author:: Noah Kantrowitz <noah@coderanger.net>
#
# Copyright 2014, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Poise
  module AppEnvironment
    def self.app_environment(node, cookbook)
      candidates = node['recipes'].map do |r|
        md = /#{cookbook}(?:::(.+)|$)/.match(r)
        md[1] || 'default' if md # cookbook::default == cookbook
      end.select {|r| r }.uniq
      candidates.delete('default') if candidates.size > 1 # If we have ['default', 'something'], we always want the something
      raise "More than one candidate environment found: #{candidates.join(', ')}" if candidates.size > 1
      raise "App cookbook #{cookbook} not found" if candidates.empty?
      # If our candidate name is default (as in cookbook::default) use chef_environment instead
      candidates.first == 'default' ? node.chef_environment : candidates.first
    end
  end

  module AppEnvironmentDSL
    def app_environment
      cookbook = node['poise-appenv']['cookbook']
      raise 'Cookbook used to determine application envionment not set' unless cookbook
      AppEnvironment.app_environment(node, cookbook)
    end

    def app_environment?(*names)
      names.flatten.include?(app_environment)
    end
  end
end

class Chef::Node
  include Poise::AppEnvironmentDSL
end
