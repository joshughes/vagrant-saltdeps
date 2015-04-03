require 'log4r'
require 'vagrant'
require 'git'
require 'fileutils'
require "log4r"


module VagrantPlugins
  module Saltdeps
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def initialize(machine, config)
        super
        @logger          = Log4r::Logger.new("vagrant::provisioner::saltdeps")
        @checkout_path   = config.checkout_path
        @grains_path     = config.grains_path
        @pillars_path    = config.pillars_path
        @merge_pillars   = config.merge_pillars
        @merge_grains    = config.merge_grains
        @merged_path     = config.merged_path
        @deps            = YAML.load_file(config.deps_path)['deps'] || {}
        @current_formula = YAML.load_file(config.deps_path)['name']
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
          g.checkout(branch)
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
        communicator = @machine.communicate
        @formula_folders.each do |folder|
          communicator.upload(folder[:host_path],folder[:guest_path])
        end
        current_path = File.expand_path(@current_formula, @machine.env.root_path)
        communicator.upload(current_path,'/srv/salt')
      end

      def cleanup
        if File.directory? @checkout_path
          FileUtils.rm_rf(@checkout_path)
        end
        if File.directory? @merged_path
          FileUtils.rm(@merged_path + '/compiled_grains') if File.exists? @merged_path + '/compiled_grains'
          FileUtils.rm(@merged_path + '/compiled_pillars') if File.exists? @merged_path + '/compiled_pillars'
        end
        cleanup_check_path = self.clean_up_path
        cleanup_folders    = @deps.keys
        cleanup_folders   << @current_formula

        cleanup_folders.each do |dep|
          FileUtils.rm_rf(cleanup_check_path + '/' + dep) if File.directory?(cleanup_check_path + '/' + dep)
        end
      end

      def merge_grains
        output_path = File.expand_path(@merged_path+'/compiled_grains', @machine.env.root_path)
        if @merge_grains
          merge(@grains_path, output_path)
          @machine.config.vm.provisioners.each do |provisioner|
            next unless provisioner.type == :salt
            provisioner.config.grains_config= output_path
          end
        end
      end

      def merge_pillars
        output_path = File.expand_path(@merged_path+'/compiled_pillars', @machine.env.root_path)
        if @merge_pillars
          merge(@pillars_path, output_path)
          @machine.config.vm.provisioners.each do |provisioner|
            next unless provisioner.type == :salt
            provisioner.config.pillar(YAML.load_file(output_path) || {})
          end
        end
      end

      def merge(path, output)
        local_path  = File.expand_path(path,  @machine.env.root_path)

        merge_object = File.exists?(local_path)  ? YAML.load_file(local_path) || {} : {}
        @formula_folders.each do |folder|
          split_host_path = folder[:host_path].split('/')
          base_dep_path = split_host_path[0..(split_host_path.length-2)].join('/')
          dep_path = File.expand_path(base_dep_path + '/' + path, @machine.env.root_path)
          merge_object.deep_merge!(YAML.load_file(dep_path) || {}) if File.exists?(dep_path)
        end

        File.open(output,  'w') {|f| f.write merge_object.to_yaml }
      end

      def clean_up_path
        checkout_path = @checkout_path.split('/')
        base_checkout_path = checkout_path[0..(checkout_path.length-2)].join('/')
        File.expand_path(base_checkout_path, @machine.env.root_path)
      end

    end
  end
end
