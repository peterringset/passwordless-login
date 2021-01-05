# Passwordless Login for App Review

This is a very small web app whose main purpose is to help you get your iOS app through app review if you're using passwordless login. Apple's reviewers will in many cases need to log in to a test account in your app to review it, and this can cause headaches if you use random generated one time passwords (OTPs). Instead of having to change how your backend or app handles authentication you can instead use this web app to display the latest message sent to a specific number from [Twilio][twilio]. This way your application code stays unchanges and is much more secure, no back doors or special cases needed!

## Prerequisites

We assume that you already have a working application using some sort of passwordless sign in, and that you're using Twilio to send your messages.

To set up this web app you first need to make sure that you have installed the [Heroku CLI][heroku-cli]. This is most easily achieved by using [Homebrew][homebrew]:

```
brew install heroku/brew/heroku
```

Then make sure that you're logged in with the CLI.

```bash
heroku login
```

## Deploying

Start by cloning this repo and navigating to the directory.

```
git clone git@github.com:eggsdesign/passwordless-login.git
cd passwordless-login
```

Then create a new app with the Heroku CLI and set it up with the Vapor build pack.

```
heroku apps:create <your-application-name> --buildpack vapor/vapor
heroku git:remote -a <your-application-name>
```

Remember to replace `<your-application-name>` with a real application name.

Then we need to set a few environment variables.

```bash
heroku config:set \
  TWILIO_ACCOUNT_SID=<twilio-account-sid> \
  TWILIO_AUTH_TOKEN=<twilio-auth-token> \
  TWILIO_TO_NUMBER=<phone-number> \
  BASIC_AUTH_REALM=Messages \
  BASIC_AUTH_USERNAME=<username> \
  BASIC_AUTH_PASSWORD=<password>
```

Remember to replace the bracketed values with real values before running this command. `TWILIO_ACCOUNT_SID` and `TWILIO_AUTH_TOKEN` can be found on the first page of your [Twilio console][twilio-console]. `TWILIO_TO_NUMBER` is the phone number that you've set up a test account with. This doesn't necessarily need to be a real phone number, but Twilio will at least need to be able to try and send messages to it. The last two variables you need to find values for are `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD`. Choose these values wisely, your application will be available on the wide web after your deploy :)

All that is left after that is to deploy to Heroku using the following instruction:

```bash
git push heroku master
```

## Note

This web app only displays messages sent in the last two minutes. If you need a longer threshold than that you can change that in the file `Sources/App/Controllers/MessageController.swift`.

## License

This app is released under the [MIT License][license]

[vapor]: https://vapor.codes
[heroku]: https://dashboard.heroku.com/apps
[twilio]: https://www.twilio.com
[twilio-console]:  https://www.twilio.com/console
[heroku-cli]: https://devcenter.heroku.com/articles/heroku-cli
[homebrew]: https://brew.sh
[license]: https://github.com/eggsdesign/passwordless-login/blob/master/LICENSE

