require 'octokit'
require 'active_support'
require 'active_support/core_ext'
require 'http'

task :run do
  client = Octokit::Client.new(access_token: ENV["GITHUB_TOKEN"])

  messages = []

  File.read("repos.txt").lines.map(&:chomp).each do |repo_name|
    compare = client.compare(repo_name, "deployed-to-production", "master")

    committer_names = compare[:commits].map { |commit|
      commit.to_h.dig(:commit, :author, :name)
    }.uniq.to_sentence

    unpdeployed_pull_requests = compare[:commits].select { |commit|
      commit[:commit][:message].start_with?("Merge pull request")
    }.compact

    next unless unpdeployed_pull_requests.first

    merge_date_of_oldest_pull_request = unpdeployed_pull_requests.first[:commit][:committer][:date]

    next unless merge_date_of_oldest_pull_request < (Time.now - 14.days)

    seconds_ago = ((Time.now - merge_date_of_oldest_pull_request).abs).round
    days_ago = seconds_ago / 1.day

    application = repo_name.gsub('alphagov/', '')
    if unpdeployed_pull_requests.size == 1
      messages << "- <https://github.com/#{repo_name}|#{application}> has <#{compare[:html_url]}|#{unpdeployed_pull_requests.size} undeployed pull request> which was merged #{days_ago} days ago. It includes commits by #{committer_names}."
    else
      messages << "- <https://github.com/#{repo_name}|#{application}> has <#{compare[:html_url]}|#{unpdeployed_pull_requests.size} undeployed pull requests>, the oldest of which was merged #{days_ago} days ago. It includes commits by #{committer_names}."
    end
  end

  message = "Hello :wave:, this is your regular badgering to deploy!\n\n#{messages.join("\n")}"

  message_payload = {
    username: "Badger",
    icon_emoji: ":badger:",
    text: message,
    mrkdwn: true,
    channel: '#2ndline',
  }

  HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))
end
