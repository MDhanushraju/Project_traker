import 'dart:async';

/// Debounces a callback by [duration]. Cancel with [cancel].
class Debounce {
  Debounce(this.duration);

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
