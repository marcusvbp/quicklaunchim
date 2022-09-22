abstract class AppStorage<T> {
  Future<void> save(T value);
  Future<T?> retrieve();
}
