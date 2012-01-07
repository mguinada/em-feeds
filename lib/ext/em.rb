module EM::Ext
  # == AliasCallbacks
  #
  # When included provides a macro to alias EM:Deferrable canonical callbacks with
  # whatever names you think are the more appropriate for your class.
  #
  module AliasCallbacks
    def self.included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods
    #
    # Macro to alias EM:Deferrable canonical callbacks
    #
    # === Example
    # class Feed
    #   alias_callbacks :ontweet, :onerror
    # end
    #
    # f = Feed.new
    #
    # f.ontweet { |t| puts t } #equivalent to f.callback { |t| puts t }
    #
    # f.onerror { puts "error" } #equivalent to f.errback { puts "error" }
    #
    def alias_callbacks(success_cb_alias, failure_cb_alias = nil)
      include EM::Deferrable unless included_modules.include?(EM::Deferrable)
      class_eval do
        define_method success_cb_alias.to_sym do |&args|
          send :callback, &args
        end

        define_method failure_cb_alias.to_sym do |&args|
          send :errback, &args
        end unless failure_cb_alias.nil?
      end
    end
  end
end

Object.send :include, EM::Ext::AliasCallbacks
