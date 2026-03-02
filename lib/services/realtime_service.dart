import 'dart:async';
import 'package:flutter/foundation.dart';

class FutureToStream<T> {
  final StreamController<List<T>> _controller =
      StreamController<List<T>>.broadcast();
  late final Stream<List<T>> stream;
  final Future<List<T>> Function() fetchFunction;
  final Duration interval;
  StreamSubscription? _subscription;

  FutureToStream({
    required this.fetchFunction,
    this.interval = const Duration(seconds: 5),
  }) {
    stream = _controller.stream;
    _init();
  }

  void _init() {
    _subscription = Stream.periodic(interval).listen((_) async {
      try {
        final data = await fetchFunction();
        if (!_controller.isClosed) {
          _controller.add(data);
        }
      } catch (e) {
        if (kDebugMode) print("Erreur dans le stream : $e");
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

class FutureToStreamObject<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();
  late final Stream<T> stream;
  final Future<T> Function() fetchFunction;
  final Duration interval;
  StreamSubscription? _subscription;

  FutureToStreamObject({
    required this.fetchFunction,
    this.interval = const Duration(seconds: 5),
  }) {
    stream = _controller.stream;
    _init();
  }

  void _init() {
    // Lancement du stream périodique
    _subscription = Stream.periodic(interval).listen((_) async {
      try {
        final data = await fetchFunction();
        if (!_controller.isClosed) {
          _controller.add(data);
        }
      } catch (e) {
        if (kDebugMode) print("Erreur dans le stream : $e");
      }
    });

    // Émission immédiate au démarrage (avant le premier intervalle)
    fetchFunction().then((data) {
      if (!_controller.isClosed) _controller.add(data);
    });
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
