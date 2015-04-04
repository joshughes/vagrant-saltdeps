require 'vagrant-Saltdeps/plugin'
require 'vagrant-Saltdeps/version'

module VagrantPlugins
  module Saltdeps
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
     I18n.load_path += Dir[File.expand_path("../../locales/*{rb,yml}", __FILE__)]
   end
end
