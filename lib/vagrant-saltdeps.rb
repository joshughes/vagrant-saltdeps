require 'vagrant-saltdeps/plugin'
require 'vagrant-saltdeps/version'

module VagrantPlugins
  module SaltDeps
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
    
  end
end
