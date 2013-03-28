#--
# Rote format helper for HTML
# (c)2005 Ross Bamford (and contributors)
#
# See 'rote.rb' or LICENSE for licence information.
# $Id$
#++
require 'erb'

module Rote
  module Format
  
    # HTML Formatting module for Rote. This module may be mixed in to any Page
    # instance to provide various HTML helpers (including those from ERB::Util).
    #
    # To use this module for a given page, simply place the following code
    # somewhere applicable to that page:
    #
    #   extend Format::HTML
    #
    # Note that +include+ cannot be used since the page code is run via
    # +instance_eval+.
    module HTML
      include ERB::Util

      #:nodoc:all
      class Tag
        def initialize(name, *args, &blk)
          @name = name
          @attrs = {}
          @content = blk ? blk.call : ""
          merge_args!(args)
        end

        def to_s
          "<#{@name}#{" #{@attrs.keys.map do |k| 
            "#{k.to_s.gsub('_', '-')}='#{@attrs[k]}'" 
          end.join(' ')}" unless @attrs.keys.empty?}>#{@content}</#{@name}>"
        end

        def method_missing(clz, *args, &blk)
          if @attrs[:class]
            @attrs[:class] += " #{clz.to_s.gsub('_', '-')}"
          else
            @attrs[:class] = clz.to_s.gsub('_', '-')
          end
          merge_args!(args)
          @content += blk.call.to_s unless blk.nil?
          self
        end

        private

        def merge_args!(args)
          args.each do |arg|
            if arg.is_a? Hash
              @attrs.merge!(arg) { |k, o, n| [o, n].flatten.join(' ') } if arg.is_a? Hash
            elsif arg.is_a? Array
              @content += arg.join(' ')
            elsif arg.is_a? Proc
              @content += arg.call.to_s
            else
              @content += arg.to_s
            end
          end
        end
      end
      
      ###################################################################
      ## HELPERS

      def tag(name, *args, &blk)
        Tag.new(name, *args, &blk)
      end

      def method_missing(*args, &blk)
        tag(*args, &blk)
      end
      
    end # HTML
  end # Format
end # Rote
