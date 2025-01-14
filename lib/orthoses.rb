# frozen_string_literal: true

require 'rbs'
require 'pathname'

require_relative 'orthoses/attribute'
require_relative 'orthoses/builder'
require_relative 'orthoses/call_tracer'
require_relative 'orthoses/constant'
require_relative 'orthoses/content'
require_relative 'orthoses/create_file_by_name'
require_relative 'orthoses/delegate_class'
require_relative 'orthoses/filter'
require_relative 'orthoses/mixin'
require_relative 'orthoses/load_rbs'
require_relative 'orthoses/object_space_all'
require_relative 'orthoses/outputable'
require_relative 'orthoses/path_helper'
require_relative 'orthoses/pp'
require_relative 'orthoses/rbs_prototype_rb'
require_relative 'orthoses/rbs_prototype_runtime'
require_relative 'orthoses/store'
require_relative 'orthoses/tap'
require_relative 'orthoses/autoload'
require_relative 'orthoses/utils'
require_relative 'orthoses/version'
require_relative 'orthoses/walk'
require_relative 'orthoses/writer'

module Orthoses
  # Use autoload just in case there are side effects.
  autoload :LazyTracePoint, 'orthoses/lazy_trace_point'

  METHOD_METHOD = ::Kernel.instance_method(:method)
  INSTANCE_METHOD_METHOD = ::Module.instance_method(:instance_method)

  class ConstLoadError < StandardError
    attr_reader :root
    attr_reader :const
    attr_reader :error
    def initialize(root:, const:, error:)
      @root = root
      @const = const
      @error = error
    end

    def message
      "root=#{root}, const=#{const}, error=#{error.inspect}"
    end
  end

  class NameSpaceError < StandardError
  end

  class << self
    attr_accessor :logger
  end
  self.logger = ::Logger.new($stdout, level: :info)
end
