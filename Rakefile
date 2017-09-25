require 'http'
require 'yaml'

require_relative './lib/message_generator'

def currently_in_deploy_freeze?
  Date.today >= Date.parse("2016-12-22") && Date.today <= Date.parse("2017-01-04")
end

def weekend?
  Date.today.saturday? || Date.today.sunday?
end

task :run do
  applications = YAML.load(HTTP.get('https://raw.githubusercontent.com/alphagov/govuk-developer-docs/master/data/applications.yml'))
  messages = applications.map { |application|
    next if application["retired"]
    MessageGenerator.new("alphagov/" + application.fetch('github_repo_name')).message
  }.compact

  if messages.any?
    message = "Hello :paw_prints:, this is your regular badgering to deploy!\n\n#{messages.join("\n")}"

    message_payload = {
      username: "Badger",
      icon_emoji: ":badger:",
      text: message,
      mrkdwn: true,
      channel: '#govuk-deploy',
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
