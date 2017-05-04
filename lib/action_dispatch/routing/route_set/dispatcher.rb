
# Monkey patch the rails dispatcher just before it hands over control to our
# controller implementation. In doing so, we can included the name of the
# controller and action to be executed in all calls to Rails.logger in the
# context of any of our application controllers.
# Note the use of `prepend` to deal with the fact that the `dispatch()` function
# is class private.

module DispatcherExtensions
  def dispatch(controller, action, env)
    Rails.logger.tagged({ controller: controller.to_s, action: action.to_s }) do
      super
    end
  end
end

module ActionDispatch
  module Routing
    class RouteSet
      class Dispatcher
        prepend DispatcherExtensions
      end
    end
  end
end
