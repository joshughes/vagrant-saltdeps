require "log4r"
require "vagrant"
require 'pry'

module VagrantPlugins
  module Saltdeps
    class Provisioner < Vagrant.plugin('2', :provisioner)

      def configure(root_config)
        binding.pry
      end

      def provision
        binding.pry
      end

    end
  end
end
