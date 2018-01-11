## lambda-form-handler

## setup
1. Copy `config.template.json` to `config.json` and fill out with Twilio info.
2. Run `npm install`
3. Change to `deploy` directory and run `terraform init`. Provide S3 details.

## usage
`npm run deploy` deploys to lambda

`npm run aws:exec` will run it on lambda

`npm run local` will run locally using local.json values

