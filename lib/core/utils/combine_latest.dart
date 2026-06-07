import 'dart:async';

/// Combines the latest values of two streams into one, re-emitting whenever
/// either source emits (once both have produced a first value). Dependency-free
/// alternative to rxdart for the few places we need to merge reactive sources.
///
/// Single-subscription: intended to back a Riverpod StreamProvider. Errors from
/// either source are forwarded; both subscriptions are cancelled on cancel.
Stream<R> combineLatest2<A, B, R>(
  Stream<A> sourceA,
  Stream<B> sourceB,
  R Function(A a, B b) combine,
) {
  late StreamController<R> controller;
  late A latestA;
  late B latestB;
  var hasA = false;
  var hasB = false;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;

  void emit() {
    if (hasA && hasB) controller.add(combine(latestA, latestB));
  }

  controller = StreamController<R>(
    onListen: () {
      subA = sourceA.listen(
        (value) {
          latestA = value;
          hasA = true;
          emit();
        },
        onError: controller.addError,
      );
      subB = sourceB.listen(
        (value) {
          latestB = value;
          hasB = true;
          emit();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
    },
  );

  return controller.stream;
}

/// Three-source variant of [combineLatest2]: re-emits whenever any source emits,
/// once all three have produced a first value. Same single-subscription, error-
/// forwarding, cancel-all semantics. Used where a derived value depends on three
/// reactive DB queries (e.g. aggregates + dates + skill-tagged session count).
Stream<R> combineLatest3<A, B, C, R>(
  Stream<A> sourceA,
  Stream<B> sourceB,
  Stream<C> sourceC,
  R Function(A a, B b, C c) combine,
) {
  late StreamController<R> controller;
  late A latestA;
  late B latestB;
  late C latestC;
  var hasA = false;
  var hasB = false;
  var hasC = false;
  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;
  StreamSubscription<C>? subC;

  void emit() {
    if (hasA && hasB && hasC) {
      controller.add(combine(latestA, latestB, latestC));
    }
  }

  controller = StreamController<R>(
    onListen: () {
      subA = sourceA.listen(
        (value) {
          latestA = value;
          hasA = true;
          emit();
        },
        onError: controller.addError,
      );
      subB = sourceB.listen(
        (value) {
          latestB = value;
          hasB = true;
          emit();
        },
        onError: controller.addError,
      );
      subC = sourceC.listen(
        (value) {
          latestC = value;
          hasC = true;
          emit();
        },
        onError: controller.addError,
      );
    },
    onCancel: () async {
      await subA?.cancel();
      await subB?.cancel();
      await subC?.cancel();
    },
  );

  return controller.stream;
}
