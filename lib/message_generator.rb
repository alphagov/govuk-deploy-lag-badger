require 'active_support'
require 'active_support/core_ext'

require_relative 'github'

class MessageGenerator
  def initialize(repo_name)
    @repo_name = repo_name
  end

  def message
    begin
      compare = GitHub.client.compare(repo_name, "deployed-to-production", "master")
    rescue Octokit::NotFound
      # Bail out if one of the branches / repos doesn't exust
      return
    end

    committer_names = compare[:commits].map { |commit|
      commit.to_h.dig(:commit, :author, :name)
    }.uniq.to_sentence

    unpdeployed_pull_requests = compare[:commits].select { |commit|
      commit[:commit][:message].start_with?("Merge pull request")
    }.compact

    return unless unpdeployed_pull_requests.first

    merge_date_of_oldest_pull_request = unpdeployed_pull_requests.first[:commit][:committer][:date]

    return unless merge_date_of_oldest_pull_request < (Time.now - 14.days)

    seconds_ago = ((Time.now - merge_date_of_oldest_pull_request).abs).round
    days_ago = seconds_ago / 1.day

    application = repo_name.gsub('alphagov/', '')

    if unpdeployed_pull_requests.size == 1
      "- <https://github.com/#{repo_name}|#{application}> has <#{compare[:html_url]}|1 undeployed pull request> which was merged #{days_ago} days ago. It includes commits by #{committer_names}."
    else
      "- <https://github.com/#{repo_name}|#{application}> has <#{compare[:html_url]}|#{unpdeployed_pull_requests.size} undeployed pull requests>, the oldest of which was merged #{days_ago} days ago. It includes commits by #{committer_names}."
    end
  end

private

  attr_reader :repo_name
end
