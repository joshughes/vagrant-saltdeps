require 'log4r'
require 'vagrant'
require 'git'
require 'pry'
require "log4r"


module VagrantPlugins
  module Saltdeps
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def initialize(machine, config)
        super
        @logger        = Log4r::Logger.new("vagrant::provisioner::saltdeps")
        @checkout_path = config.checkout_path
        @grains_path   = config.grains_path
        @pillars_path  = config.pillars_path
        @merge_pillars = config.merge_pillars
        @merge_grains  = config.merge_grains
        @merged_path   = config.merged_path
        @deps          = YAML.load_file(config.deps_path)
        @formula_folders = []
      end

      def configure(root_config)
        checkout_deps
        link_deps(root_config)
        merge_grains
        merge_pillars
      end

      def checkout_deps
        @deps.each do |name,props|
          uri    = props.fetch('git', 'foobar')
          name   = "#{name}-formula"
          branch = props.fetch('branch','master')

          if File.directory? @checkout_path + "/#{name}"
            g = Git.open @checkout_path + "/#{name}"
          else
            g = Git.clone(uri, name, path: @checkout_path)
          end
          g.branch(branch).checkout
          g.fetch
        end
      end

      def link_deps(root_config)
        @deps.each do |name, props|
          base_path = @checkout_path + "/#{name}-formula/"
          if File.directory? base_path + "#{name}"
            @formula_folders << {host_path: base_path + "#{name}", guest_path: '/srv/salt'}
          else
            @machine.ui.warn("Not creating shared folder for dependency #{name} because no folder was found at #{base_path + name}")
          end

        end
      end

      def provision
        @formula_folders.each do |folder|
          communicator = @machine.communicate
          communicator.upload(folder[:host_path],folder[:guest_path])
        end
      end

      def merge_grains
        output_path = File.expand_path(@merged_path+'/compiled_grains', @machine.env.root_path)
        merge(@grains_path, output_path) if @merge_grains
        @machine.config.vm.provisioners.each do |provisioner|
          next unless provisioner.type == :salt
          provisioner.config.grains_config= output_path
        end
      end

      def merge_pillars
        output_path = File.expand_path(@merged_path+'/compiled_pillars', @machine.env.root_path)
        merge(@pillars_path, output_path) if @merge_pillars
        @machine.config.vm.provisioners.each do |provisioner|
          next unless provisioner.type == :salt
          provisioner.config.pillar(YAML.load_file(output_path))
          binding.pry
        end
      end

      def merge(path, output)
        local_path  = File.expand_path(path,  @machine.env.root_path)

        merge_object = File.exist?(local_path)  ? YAML.load_file(local_path)  : {}
        @formula_folders.each do |folder|
          split_host_path = folder[:host_path].split('/')
          base_dep_path = split_host_path[0..(split_host_path.length-2)].join('/')
          dep_path = File.expand_path(base_dep_path + '/' + path, @machine.env.root_path)
          merge_object.deep_merge!(YAML.load_file(dep_path)) if File.exist?(dep_path)
        end

        File.open(output,  'w') {|f| f.write merge_object.to_yaml }
      end

    end
  end
end
