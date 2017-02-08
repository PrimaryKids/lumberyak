
require 'lumber-yak'

describe LumberYak do


  subject { -> { LumberYak.setup(application_config) } }
  let(:application_config) do
    config = ActiveSupport::OrderedOptions.new.tap do |config|
      config.lumberyak = ActiveSupport::OrderedOptions.new
      config.lumberyak.configure_lograge = enable_lograge?
      config.lumberyak.configure_logger = configure_logger?
      config.lumberyak.log_location = "/tmp/logs"
      config.lumberyak.log_tags = log_tags
      config.lograge = ActiveSupport::OrderedOptions.new(lograge_config)
    end
    app_config = double(config: config)
    allow(app_config).to receive(:configure).and_yield(config)
    app_config
  end
  let(:enable_lograge?) { false }
  let(:configure_logger?) { false }
  let(:lograge_config) { {} }
  let(:log_tags) { nil }

  # config.lumberyak.configure_lograge = true
  describe "configure_lograge" do

    context "when true" do
      let(:lograge_config) {
        { enabled: false }
      }
      let(:enable_lograge?) {
        true
      }
      it "enables lograge" do
        expect(subject).to change { application_config.config.lograge[:enabled] }.to(true)
      end
    end

    context "when false" do
      let(:enable_lograge?) {
        false
      }
      let(:lograge_config) {
        { enabled: false }
      }
      it "doesn't touch lograge" do
        expect(subject).to_not change { application_config.config.lograge }
      end

    end

    # config.lumberyak.configure_logger
    describe "configure_logger" do
      context "when false" do
        let(:configure_logger?) { false }
        it "ignores the application logger" do
          expect(subject).to_not change { application_config.config.logger }
        end
      end
      context "when true" do
        let(:configure_logger?) { true }
        it "overrides the application logger" do
          expect(subject).to change { application_config.config.logger }
        end
      end
    end


#   config.lumberyak.log_tags = nil
    describe "log_tags" do
      let(:log_tags) { [:uuid] }
      it "sets the tagged logger's set of tags" do
        expect(subject).to change { application_config.config.log_tags }
      end
    end
#   config.lumberyak.enabled = false

  end
end
