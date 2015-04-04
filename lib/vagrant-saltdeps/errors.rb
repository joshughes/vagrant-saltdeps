

module VagrantPlugins
  module Saltdeps
    class GitCheckoutError < Vagrant::Errors::VagrantError
      error_key "git_checkout_error"
    end
    class UnknownException < Vagrant::Errors::VagrantError
      error_key "unknown_error"
    end
  end
end