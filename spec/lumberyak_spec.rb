
require 'lumberyak'

require 'active_support/core_ext/string/filters'

# Need to disable verification of partial doubles so we can
# set the logger on the Rails module.
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = false
  end
end

describe LumberYak do
  subject { -> { LumberYak.setup(application_config) } }
  let(:application_config) do
    config_set = ActiveSupport::OrderedOptions.new.tap do |config|
      config.lumberyak = ActiveSupport::OrderedOptions.new
      config.lumberyak.configure_lograge = enable_lograge?
      config.lumberyak.log_location = "/tmp/logs"
      config.lumberyak.log_tags = log_tags

      config.lograge = ActiveSupport::OrderedOptions.new(lograge_config)

      config.logger = logger
    end
    app_config = double(config: config_set)
    allow(app_config).to receive(:configure).and_yield(config_set)
    allow(Rails).to receive(:logger=)
    app_config
  end

  let(:logger) { ActiveSupport::Logger.new("/dev/null") }
  let(:enable_lograge?) { false }
  let(:lograge_config) { {} }
  let(:log_tags) { nil }

  describe "configure_lograge" do
    context "when false" do
      let(:enable_lograge?) do
        false
      end
      let(:lograge_config) do
        { enabled: false }
      end
      it "doesn't touch lograge" do
        expect(subject).to_not change { application_config.config.lograge }
      end
    end

    describe "setup_logger" do
      it "Forces a TaggedLogger on to the users logger" do
        # Need to retain a copy of the app through out this type of test
        # because multiple calls to application_config() result in a diff
        # app instance so the change to the one past to LumberYak.setup()
        # won't be observed.
        # Also note that I'm not using expect(subject).to change {...}.
        # TaggedLogger.new doesn't create a separate object, but instead injects a module
        # into the Logger object you supply. So in this sense, app.config.logger will
        # still point to the same object instance at the end of the test, even if that
        # object has been modified by adding new methods.
        app = application_config
        LumberYak.setup(app)
        expect(app.config.logger).to respond_to(:tagged)
      end

      describe "with a nil logger" do
        let(:logger) { nil }
        it "does not override a logger" do
          LumberYak.setup(application_config)
          expect(ActiveSupport::TaggedLogging).not_to receive(:new)
        end
      end
    end

    describe "log_tags" do
      let(:log_tags) { [:uuid] }
      it "sets the tagged logger's set of tags" do
        expect(subject).to change { application_config.config.log_tags }
      end
    end
  end
end
