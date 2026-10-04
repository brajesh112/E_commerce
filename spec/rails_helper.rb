require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "webmock/rspec"
require "shoulda/matchers"

# Load support files (shared contexts, helpers).
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# No real outbound HTTP in the suite (localhost allowed for Capybara/AS).
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join("spec", "fixtures")]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Factories
  config.include FactoryBot::Syntax::Methods

  # Devise auth in request/controller specs
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Run every job inline-testable: enqueue, don't perform, unless asked.
  config.before(:each) { ActiveJob::Base.queue_adapter = :test }
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
