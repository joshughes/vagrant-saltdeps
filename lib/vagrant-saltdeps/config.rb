module VagrantPlugins
  module Saltdeps
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :foo

      def initialize
        super
        @foo = UNSET_VALUE
      end


      def finalize!
        @foo = [] if @foo == UNSET_VALUE
      end


    end
  end
end
