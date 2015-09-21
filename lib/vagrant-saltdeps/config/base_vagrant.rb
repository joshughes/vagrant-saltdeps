module VagrantPlugins
  module Saltdeps
    module Config
      class Basevagrant < Vagrant.plugin('2', :config)
        attr_accessor :base_vagrantfile

        def initialize
          super
          @base_vagrantfile = UNSET_VALUE
        end

        def validate(machine)

        end

        def finalize!
          @base_vagrantfile   = 'foobar' if @base_vagrantfile  == UNSET_VALUE
        end

        private

        def expand(path, errors=[], check=false)
          expanded = Pathname.new(@deps_path).expand_path(@machine.env.root_path)
          if check && !expanded.file?
            errors << "The file at #{expanded} does not exist. Please give a valid path to your saltdeps.yml file."
          end
        end


      end
    end
  end
end
