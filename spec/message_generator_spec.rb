require "spec_helper"
require "vcr"
require "webmock/rspec"
require "timecop"

require_relative "./../lib/message_generator"

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end

RSpec.describe MessageGenerator do
  before do
    Timecop.freeze("2016-12-06 12:00")
  end

  it "generates a proper message for a repo with some undeployed pull requests" do
    VCR.use_cassette("multipage-frontend") do
      message = MessageGenerator.new("alphagov/multipage-frontend").message

      expect(message).to eql(
        "- <https://release.publishing.service.gov.uk/applications/multipage-frontend|multipage-frontend> has " \
        "<https://github.com/alphagov/multipage-frontend/compare/deployed-to-production...master|3 " \
        "undeployed pull requests>, the oldest of which was merged 17 days " \
        "ago. It includes commits by Daniel Roseman, Tijmen Brommet, Steve " \
        "Laing, and Carlos Vilhena."
      )
    end
  end

  it "generates a proper message for a repo with one undeployed pull requests" do
    VCR.use_cassette("business-support-api") do
      message = MessageGenerator.new("alphagov/business-support-api").message

      expect(message).to eql(
        "- <https://release.publishing.service.gov.uk/applications/business-support-api|business-support-api> " \
        "has <https://github.com/alphagov/business-support-api/compare/deployed-to-production...master|1 " \
        "undeployed pull request> which was merged 42 days ago. It includes " \
        "commits by Murray Steele and Simon."
      )
    end
  end

  it "corrects the slug for inconsistently named applications" do
    VCR.use_cassette("contacts-admin") do
      message = MessageGenerator.new("alphagov/contacts-admin").message

      expect(message).to eql(
        "- <https://release.publishing.service.gov.uk/applications/contacts|contacts-admin> " \
        "has <https://github.com/alphagov/contacts-admin/compare/deployed-to-production...master|1 " \
        "undeployed pull request> which was merged 8 days ago. It includes " \
        "commits by dependabot[bot] and Simon."
      )
    end
  end

  it "generates no proper message a repo without any undeployed pull requests" do
    VCR.use_cassette("rummager") do
      message = MessageGenerator.new("alphagov/rummager").message

      expect(message).to eql(nil)
    end
  end

  it "generates no proper message a repo with undeployed PRs, but none too old" do
    VCR.use_cassette("publishing-api") do
      message = MessageGenerator.new("alphagov/publishing-api").message

      expect(message).to eql(nil)
    end
  end
end
