require "action_controller"
require "test_helper"

class TestController < ActionController::Base
  def initialize(routes)
    @routes = routes
  end

  def _routes
    @routes
  end

  def show
    head :not_found
  end
end

class ParamsFormattableTest < ActionController::TestCase
  def setup
    # default configuration
    Flog.configure do |config|
      config.params_key_count_threshold = 1
      config.force_on_nested_params = true
    end

    @old_logger = ActionController::Base.logger
    ActiveSupport::LogSubscriber.colorize_logging = false
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
        get "test/show", to: "test#show"
      end
    @controller = TestController.new(@routes)
    super
    ActionController::Base.logger = TestLogger.new
  end

  def teardown
    super
    ActionController::Base.logger = @old_logger
  end

  def test_parameters_log_is_formatted
    get_show foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      logs = logger.infos.map { |log| remove_color_seq(log) }
      assert_equal "  Parameters: ", logs[1]
      hash = hash_from_logs(logs, 2, 5)
      assert_equal hash["foo"], "foo_value"
      assert_equal hash["bar"], "bar_value"
    end
  end

  def test_colorized_on_colorize_loggin_is_true
    ActiveSupport::LogSubscriber.colorize_logging = true
    get_show foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      assert match_color_seq(logger.infos.join())
    end
  end

  def test_not_colorized_on_colorize_loggin_is_false
    Flog::Status.stub(:enabled?, true) do
      get_show foo: "foo_value", bar: "bar_value"
      assert_logger do |logger|
        assert_nil match_color_seq(logger.infos.join())
      end
    end
  end

  def test_parameters_log_is_not_formatted_when_enabled_is_false
    Flog::Status.stub(:enabled?, false) do
      get_show foo: "foo_value", bar: "bar_value"
      assert_logger do |logger|
        assert logger.infos[1].include?("Parameters: {")
        assert logger.infos[1].include?(%("foo"=>"foo_value"))
        assert logger.infos[1].include?(%("bar"=>"bar_value"))
      end
    end
  end

  def test_parameters_log_is_not_formatted_when_params_formattable_is_false
    Flog::Status.stub(:params_formattable?, false) do
      get_show foo: "foo_value", bar: "bar_value"
      assert_logger do |logger|
        assert logger.infos[1].include?("Parameters: {")
        assert logger.infos[1].include?(%("foo"=>"foo_value"))
        assert logger.infos[1].include?(%("bar"=>"bar_value"))
      end
    end
  end

  def test_parameters_log_is_not_formatted_when_key_of_parameters_count_equals_to_configured_threshold
    Flog.configure do |config|
      config.params_key_count_threshold = 2
    end
    get_show foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      assert logger.infos[1].include?("Parameters: {")
      assert logger.infos[1].include?(%("foo"=>"foo_value"))
      assert logger.infos[1].include?(%("bar"=>"bar_value"))
    end
  end

  def test_parameters_log_is_not_formatted_when_key_of_parameters_count_is_under_configured_threshold
    Flog.configure do |config|
      config.params_key_count_threshold = 3
    end
    get_show foo: "foo_value", bar: "bar_value"
    assert_logger do |logger|
      assert logger.infos[1].include?("Parameters: {")
      assert logger.infos[1].include?(%("foo"=>"foo_value"))
      assert logger.infos[1].include?(%("bar"=>"bar_value"))
    end
  end

  def test_parameters_log_is_formatted_when_key_of_parameters_count_is_under_configured_threshold_but_force_on_nested_params_configuration_is_true
    Flog.configure do |config|
      config.params_key_count_threshold = 3
    end
    get_show foo: "foo_value", bar: { prop: "prop_value", attr: "attr_value" }
    assert_logger do |logger|
      logs = logger.infos.map { |log| remove_color_seq(log) }
      assert_equal "  Parameters: ", logs[1]
      hash = hash_from_logs(logs, 2, 8)
      assert_equal hash["foo"], "foo_value"
      assert_equal hash["bar"]["prop"], "prop_value"
      assert_equal hash["bar"]["attr"], "attr_value"
    end
  end

  private
  def assert_logger(&block)
    if ActionController::Base.logger.errors.present?
      fail ActionController::Base.logger.errors.first
    else
      block.call(ActionController::Base.logger)
    end
  end

  def get_show(params)
    if Gem::Version.new(Rails.version) >= Gem::Version.new("5.0.0")
      get :show, params: params
    else
      get :show, params
    end
  end

  def hash_from_logs(logs, start, finish)
    eval(start.upto(finish).reduce("") { |s, n| s + logs[n] })
  end
end
