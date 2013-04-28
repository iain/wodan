require "wodan/version"
require "wodan/execute_use_case"
require "wodan/domain"

module Wodan

  def self.call(*args)
    ExecuteUseCase.call(*args)
  end

end
