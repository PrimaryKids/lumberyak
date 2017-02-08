

# We don't want Log Rage to do any message formatting as our JSON
# encoding owns this step.  Otherwise we end up with a json encoded
# message within a json blob.
module Lograge
  module Formatters
    class NoFormat
      def call(data)
        data
      end
    end
  end
end
