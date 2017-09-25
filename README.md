# Deploy lag badger

Posts a message to the GOV.UK #govuk-deploy Slack channel if there are applications
with pull requests that have not been deployed after 2 weeks.

## Deployment

A Jenkins job is set up to run every day. It uses master, so no deployment is
necessary.

## Testing locally

To run the script:

```
bundle exec rake run
```

By default the script doesn't post to Slack, so this is safe.

### Running the test suite

```
bundle exec rspec
```

## Licence

[MIT License](LICENCE)
