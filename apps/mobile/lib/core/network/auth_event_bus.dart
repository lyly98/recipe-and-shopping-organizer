import 'dart:async';

/// Broadcast stream for HTTP 401 Unauthorized events.
///
/// The Dio interceptor adds an event here whenever a 401 response is received.
/// [AuthNotifier] listens to this stream and triggers logout automatically,
/// avoiding a circular import between network_providers and auth_provider.
final StreamController<void> unauthorizedEventController =
    StreamController<void>.broadcast();
