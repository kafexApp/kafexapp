/// Classe que encapsula o resultado de operações assíncronas
/// Facilita tratamento de erros e estados de loading
sealed class Result<T> {
  const Result();
  
  factory Result.ok(T value) = Ok<T>;
  factory Result.error(Exception error) = Error<T>;
  
  bool get isOk => this is Ok<T>;
  bool get isError => this is Error<T>;
  
  Ok<T> get asOk => this as Ok<T>;
  Error<T> get asError => this as Error<T>;
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Error<T> extends Result<T> {
  final Exception error;
  const Error(this.error);
}