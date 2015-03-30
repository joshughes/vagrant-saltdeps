require "log4r"
require "vagrant"
require 'pry'

module VagrantPlugins
  module SaltDeps
    class Provisioner < Vagrant.plugin('2', :provisioner)

      def configure(root_config)
        binding.pry
      end

      def provision
        binding.pry
      end

      def cleanup
        binding.pry
      end
    end
  end
end
