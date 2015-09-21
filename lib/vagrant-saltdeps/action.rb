require 'pry'
module Vagrant
  module Saltdeps
    class Action
      def initialize(app, env)
        @app = app
      end

      def call(env)
         config_loader = env[:env].config_loader
         config_loader.set(:tmp, '/tmp/Vagrantfile')
         env[:env].instance_variable_set(:@vagrantfile, Vagrantfile.new(config_loader, [:home, :tmp, :root]))
         binding.pry
      end

    end
  end
end
