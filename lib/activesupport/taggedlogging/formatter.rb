
module ActiveSupport
  module TaggedLogging
    module Formatter # :nodoc:
      # This method is invoked when a log event occurs.
      def call(severity, timestamp, progname, message)
        # This scheme of serializing text log messages into a json format is
        # loosely based on the logstasher.log() method found here:
        # https://github.com/shadabahmed/logstasher/blob/master/lib/logstasher.rb#L160
        # The major difference is we use the TaggedLogging formater's tagging ability.
        # As implemented, TaggedLogging expects the proc's it executes return a scalar
        # value which it converts to a string wrapped with brackets. The resulting
        # behavior is logs that take the form of:
        # '[23432342] [234245] error parsing post request'
        # We could have left that intact by say having a tags field in our json doc that
        # points to our list of tags, but this lacks context. So what we've done is change
        # the convention in our application.rb to have our callback procs return hashes
        # instead of scalars. This way, we get the context by letting the proc provide keys
        # that describe each value.
        data = { 'level' => severity }
        if message.is_a? StandardError
          e = message
          data['type'] = e.class.to_s
          data['message'] = e.message
          data['backtrace'] = clean_backtrace(e).join("\n    ")
        elsif message.respond_to?(:to_hash)
          data.merge!(message.to_hash)
        else
          data['message'] = message
        end
        data['timestamp'] = timestamp.iso8601

        data.merge!(user_defined_attributes)

        super(severity, timestamp, progname, data.to_json)
      end

      def user_defined_attributes
        attrs = {
          "tags" => []
        }
        current_tags.each do |t|
          if t.respond_to?(:to_hash)
            attrs.merge!(t.to_hash)
          else
            attrs["tags"].push(t)
          end
        end
        attrs
      end

      # Taken from http://stackoverflow.com/a/237846
      def clean_backtrace(exception)
        if backtrace = exception.backtrace
          if defined?(RAILS_ROOT)
            backtrace.map { |line| line.sub RAILS_ROOT, '' }
          else
            backtrace
          end
        end
      end
    end
  end
end
