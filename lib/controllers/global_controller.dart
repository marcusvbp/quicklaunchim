abstract class GlobalController<T> {
  void set(T value);
  Future<void> rehydrate();
}
