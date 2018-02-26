require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'http'
require 'json'

require_relative './lib/message_generator'

def currently_in_deploy_freeze?
  Date.today >= Date.parse("2016-12-22") && Date.today <= Date.parse("2017-01-04")
end

def weekend?
  Date.today.saturday? || Date.today.sunday?
end

desc "Run the deploy lag badger"
task :run do
  applications = JSON.parse(HTTP.get('https://docs.publishing.service.gov.uk/apps.json'))
  messages = applications.map { |application|
    github_owner_and_repo = application.dig('links', 'repo_url').gsub('https://github.com/', '')
    MessageGenerator.new(github_owner_and_repo).message
  }.compact

  if messages.any?
    message = "Hello :paw_prints:, this is your <https://github.com/alphagov/govuk-deploy-lag-badger|regular badgering to deploy>!\n\n#{messages.join("\n")}"

    message_payload = {
      username: "Badger",
      icon_emoji: ":badger:",
      text: message,
      mrkdwn: true,
      channel: '#govuk-developers',
    }

    puts message

    if weekend?
      puts "Not posting anything, it's the weekend"
      next
    end

    if currently_in_deploy_freeze?
      puts "Not posting anything, we're in a deploy freeze period"
      next
    end

    if ENV['REALLY_POST_TO_SLACK'] != "1"
      puts "Not posting anything, this is a dry run"
      next
    end

    HTTP.post(ENV.fetch("BADGER_SLACK_WEBHOOK_URL"), body: JSON.dump(message_payload))
  end
end
