# Vouch household app

This Flutter app manages household members, rules, approvals and activity. Its Alexa tab is a simulated client that sends MCP requests to the Vouch backend. Speaker identity and the owner-phone view are simulated in the no-hub demo.

Follow the [root setup guide](../../README.md#fastest-way-to-try-it-no-hub-no-mic) to start the backend and app together. Select **Try the demo household (no hub)** to test preset requests without a microphone or model key.

## Development

Run from this directory after workspace dependencies are installed:

```sh
flutter analyze
flutter test
```

Controllers live in `lib/logic/`, repositories in `lib/data/`, and screens in `lib/screens/`. The [design guide](lib/design/DESIGN.md) defines colours, typography and motion. Use the [deployment checklist](../vouch_server/DEPLOY.md) before building a public web demo.
