final injector = {};

T get<T>() => injector[T] as T;

void put<T>(T instance) {
  injector[T] = instance;
}
