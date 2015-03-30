begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant Saltdeps plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.2.0"
  raise "The Vagrant Saltdeps plugin is only compatible with Vagrant 1.2+"
end

module VagrantPlugins
  module SaltDeps
    class Plugin < Vagrant.plugin("2")
      name "saltdeps"
      description <<-DESC
      This plugin manages salt formula dependencies.
      DESC

      config(:saltdeps, :provisioner) do
        require File.expand_path("../config", __FILE__)
        Config
      end

      provisioner(:saltdeps) do

        # Return the provider
        require File.expand_path("../provisioner", __FILE__)
        Provisioner
      end


    end
  end
end
