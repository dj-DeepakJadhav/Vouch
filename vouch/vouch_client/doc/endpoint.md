# Endpoint calls

The generated `Client` exposes backend methods as `client.endpoint.method()`. For example, the household app calls:

```dart
final household = await client.household.myHousehold();
```

The backend resolves the household from the authenticated session. A fresh session must enter the demo household or complete pairing before household requests succeed.

Endpoint implementations live in `vouch/vouch_server/lib/src/`. Serverpod regenerates the typed client when their definitions change.
