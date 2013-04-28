require "wodan/execute_use_case"

module Wodan
  class Domain

    def self.use_case(name, opts = {})
      mod = const_defined?(:UseCases) ? const_get(:UseCases) : const_set(:UseCases, Module.new)
      mod.instance_eval do
        define_method name do |*args|
          execute_use_case(name, opts, *args)
        end
      end
      include mod
    end

    private

    def execute_use_case(name, opts = {}, *args)
      use_case = self.class.const_get opts.fetch(:class)
      Wodan.call(use_case, self, *args)
    end

  end
end
