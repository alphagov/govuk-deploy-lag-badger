require "active_support"
require "active_support/core_ext"

require_relative "github"

class MessageGenerator
  APP_SLUG_OVERRIDES = {
    "contacts-admin" => "contacts",
    "ckanext-datagovuk" => "ckan",
    "licence-finder" => "licencefinder",
    "smart-answers" => "smartanswers",
  }.freeze

  RELEASE_APP_PATH = "https://release.publishing.service.gov.uk/applications/".freeze

  def initialize(repo_name)
    @repo_name = repo_name
  end

  def message
    committer_names = rand(1..5).times.map { "<redacted>" }.to_sentence
    undeployed_pull_requests = rand(0...10).times.map { "" }
    undeployed_pull_requests = [] unless rand(0...4) == 0
    days_ago = rand(1..10)

    return if repo_name =~ /govuk/
    return unless undeployed_pull_requests.any?

    if undeployed_pull_requests.size == 1
      "- <#{RELEASE_APP_PATH}#{app_slug}|#{app_name}> has <http://google.com|1 undeployed pull request> which was merged #{days_ago} days ago. It includes commits by #{committer_names}."
    else
      "- <#{RELEASE_APP_PATH}#{app_slug}|#{app_name}> has <http://google.com|#{undeployed_pull_requests.size} undeployed pull requests>, the oldest of which was merged #{days_ago} days ago. It includes commits by #{committer_names}."
    end
  end

private

  def app_name
    repo_name.gsub("alphagov/", "")
  end

  def app_slug
    APP_SLUG_OVERRIDES[app_name] || app_name
  end

  attr_reader :repo_name
end
