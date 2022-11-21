require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Lint ruby"
task :lint do
  sh "bundle exec rubocop --format clang"
end

task default: %i[lint spec]

require "http"
require "json"

require_relative "./lib/message_generator"

def currently_in_deploy_freeze?
  Date.today >= Date.parse("2016-12-22") && Date.today <= Date.parse("2017-01-04")
end

def weekend?
  Date.today.saturday? || Date.today.sunday?
end

def random_parrot
  %w[
    angel_parrot
    aussieparrot
    ceiling_parrot
    coffeeparrot
    congaparrot
    darkbeerparrot
    discoparrot
    fasterparrot
    fiesta_parrot
    gentleman_parrot
    ice_cream_parrot
    jediparrot
    jenkins_parrot
    loveparrot
    mardi_gras_parrot
    oldtimeyparrot
    parrot
    ship_it_parrot
    skiparrot
    shuffleparrot
    ultrafastparrot
  ].sample
end

desc "Run the deploy lag badger"
task :run do
  JSON.parse(HTTP.get("https://docs.publishing.service.gov.uk/apps.json")).group_by { |app| app["team"] }.each do |team, applications|
    messages = applications.map { |application|
      github_owner_and_repo = application.dig("links", "repo_url").gsub("https://github.com/", "")
      MessageGenerator.new(github_owner_and_repo).message
    }.compact

    message = if messages.any?
                "Hello :paw_prints:, this is your <https://github.com/alphagov/govuk-deploy-lag-badger|regular badgering to deploy>!\n\n#{messages.join("\n")}"
              else
                "Hello :paw_prints:, there aren't any undeployed pull requests older than 7 days. GOOD JOB TEAM! :#{random_parrot}:"
              end

    message_payload = {
      username: "Badger",
      icon_emoji: ":badger:",
      text: message,
      mrkdwn: true,
      channel: team,
    }

    puts
    puts "Message for #{team}:"
    puts message

    if weekend?
      puts "Not posting anything, it's the weekend"
      next
    end

    if currently_in_deploy_freeze?
      puts "Not posting anything, we're in a deploy freeze period"
      next
    end

    if ENV["REALLY_POST_TO_SLACK"] != "1"
      puts "Not posting anything, this is a dry run"
      next
    end

    HTTP.post(ENV.fetch("BADGER_SLACK_WEBHOOK_URL"), body: JSON.dump(message_payload))
  end
end
