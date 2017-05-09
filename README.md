


# LumberYak - Structured logging for Rails Applications


LumberYak provides a drop in solution for structured logging in Rails applications. So you can easily slice and dice them in your log analysis tool of choice. 

Some features include:
* Drop in formatting of logs in JSON.
* Native integration with [LogRage](https://github.com/roidrage/lograge) to limit Rails verbosity and collect request metrics into attributes.
* Backwards compatibility with [ActiveSupport::TaggedLogging](http://api.rubyonrails.org/classes/ActiveSupport/TaggedLogging.html).
* Added support for key/value based tags in addition to primitive data types.
* Auto formatting of exception objects.


## Installation

Via the command line:
```shell
gem install lumberyak
```

Or inside of a `Gemfile`:

```ruby
gem "lumberyak"
```

Add an initializer to your Rails project:
`config/initializers/lumberyak.rb`

```ruby
Rails.application.configure do
  config.lumberyak.enabled = true
end
```

## Configuration Options


```ruby
Rails.application.configure do

  # Whether or not LumberYak should be enabled. Defaults to `false`.
  config.lumberyak.enabled = true

  # Whether or not LumberYak should enable an configure LogRage. This Gem tends
  # to be quite opinionated so if you prefer Rails logging out of the box you may
  # wish to disable this. Note that LogRage does require a specific Formatter to
  # work with LumberYak.  LumberYak will configure this for you if the following
  # is true.
  config.lumberyak.configure_lograge = true

  
  # A list of: methods that the request object responds to, a Proc that accepts
  # the request object, or something that responds to 'to_hash' or 'to_s'. Note
  # that if you already have a `config.log_tags` in your application config that
  # you do not need this setting. If both are set LumberYak will default to this
  # setting.
  config.lumberyak.log_tags = nil

end
```

## Usage
Since LumberYak is backwards compatible with `ActiveSupport::TaggedLogging`, any existing calls like the following will work:

```ruby
# Logs: { "message": "Stuff", "tags": ["BCX"] }
Rails.logger.tagged("BCX") { Rails.logger.info "Stuff" }                            

# Logs: { "message": "Stuff", "tags": ["BCX", "Jason"] }
Rails.logger.tagged("BCX", "Jason") { Rails.logger.info "Stuff" }                  

# Logs: { "message": "Stuff", "tags": ["BCX", "Jason"] }
Rails.logger.tagged("BCX") { Rails.logger.tagged("Jason") { Rails.logger.info "Stuff" } }
```


But with LumberYak enabled, you can now use hash values both for tags and log messages. 

```ruby
# Logs: { "message": "Stuff", "item_id": "BCX" }
Rails.logger.tagged({ item_id: "BCX" }) { Rails.logger.info "Stuff" }                            

# Logs: { "message": "Stuff", "item_id": "BCX", "user_name": "Jason" }
Rails.logger.tagged({ item_id: "BCX", user_name: "Jason"}) { Rails.logger.info "Stuff" }

# Logs: { "item_id": "BCX", "user_name": "Jason", "item_action": "Stuff" }"
Rails.logger.tagged({ item_id: "BCX", user_name: "Jason"}) { Rails.logger.info({ item_action: "Stuff" }) }
```

LumberYak will also autoformat any exception objects that are logged.

```ruby

def index
  begin
    i = 1 / 0
  rescue Exception => e
    Rails.logger.tagged({ forced_error: true }) { Rails.logger.error e }
  end
end

# Will log the following:
# {
#   "level":"ERROR",
#   "type":"ZeroDivisionError",
#   "message":"divided by 0",
#   "backtrace":".....",
#   "timestamp":"2017-04-13T23:51:37+00:00",
#   "tags":[],
#   "forced_error: true
# }
```

## `config.log_tags`
The Rails TaggedLogger can optionally use a configuration setting named `log_tags`. This setting is a list that contains either strings for literal values, symbols naming functions on the request objects whose return value you'd wish to include, or a proc whose return value will be included.  For instance, for the following setting:

```ruby
    config.log_tags = [
      "my logs rock",
      :uuid,
      proc do |request|
        request.session.id
      end
    ]
```

This would generate logs that look like:
`[my logs rock] [29adec3c2] [39dab3f0] Processing by HomeController#index as HTML`

However, we can rewrite this to use LumberYak's support for hashes to rewrite our tags:

```ruby
    config.log_tags = [
      proc do |request|
        {
          my_logs_what: "my logs rock",
          request_id: request.uuid,
          session_id: request.session.id
        }
      end
    ]
```

Then our logs will look like the following:
```json
{
  "my_logs_what": "my logs rock",
  "request_id": "29adec3c2",
  "session_id": "39dab3f0",
  "message": "Processing by HomeController#index as HTML"
}
```
