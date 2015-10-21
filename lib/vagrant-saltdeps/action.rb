require 'git'

module Vagrant
  module Saltdeps
    class Action
      def initialize(app, env)
        @app = app
      end

      def call(env)
         base_vagrantfile = Vagrant::Plugin::V2::Config.const_get(:UNSET_VALUE)
         checkout_path = Vagrant::Plugin::V2::Config.const_get(:UNSET_VALUE)
         config_loader = env[:env].config_loader

         v = Vagrantfile.new(config_loader, [:home,:root])
         v.config.vm.provisioners.each do |provisioner|
           if provisioner.config.class.to_s == 'VagrantPlugins::Saltdeps::Config::Provisioner'
             base_vagrantfile = provisioner.config.base_vagrantfile
             checkout_path = provisioner.config.checkout_path
           end
         end

         if base_vagrantfile != Vagrant::Plugin::V2::Config.const_get(:UNSET_VALUE)
           uri    = base_vagrantfile
           name   = "base-vagrantfile"
           branch = 'master'

           if File.directory? checkout_path + "/#{name}"
             g = Git.open checkout_path + "/#{name}"
           else
             g = Git.clone(uri, name, path: checkout_path)
           end
           begin
             g.checkout(branch)
             g.pull
           rescue  Git::GitExecuteError => e
             message = " Git error: #{e.message}"
             raise StandardError.new(message)
           end

           config_loader.set(:base_vagrantfile, "#{checkout_path}/#{name}/Vagrantfile")
           env[:env].instance_variable_set(:@vagrantfile, Vagrantfile.new(config_loader, [:home, :base_vagrantfile, :root]))
         end
      end
    end
  end
end
