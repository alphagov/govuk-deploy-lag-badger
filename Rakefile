require 'http'

require_relative './lib/message_generator'

task :run do
  messages = File.read("repos.txt").lines.map(&:chomp).map { |repo_name|
    MessageGenerator.new(repo_name).message
  }.compact

  if messages.any?
    message = "Hello :wave:, this is your regular badgering to deploy!\n\n#{messages.join("\n")}"

    message_payload = {
      username: "Badger",
      icon_emoji: ":badger:",
      text: message,
      mrkdwn: true,
      channel: '#2ndline',
    }

    puts message

    if ENV['REALLY_POST_TO_SLACK'] == "1"
      HTTP.post(ENV["BADGER_SLACK_WEBHOOK_URL"], body: JSON.dump(message_payload))
    end
  end
end
