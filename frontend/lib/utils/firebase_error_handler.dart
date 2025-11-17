// lib/utils/firebase_error_handler.dart
class FirebaseErrorHandler {
  static bool isFirebaseError(dynamic error) {
    if (error == null) return false;
    final errorString = error.toString();
    return errorString.contains('FirebaseError') ||
        errorString.contains('firebase') ||
        errorString.contains('permission-denied') ||
        errorString.contains('not-found') ||
        errorString.contains('unauthenticated') ||
        errorString.contains('network-error') ||
        errorString.contains('already-exists');
  }

  static String getErrorMessage(dynamic error) {
    if (error == null) return 'Unknown error';

    final errorString = error.toString();

    // Firebase specific errors
    if (errorString.contains('permission-denied')) {
      return 'Brak uprawnień do wykonania tej operacji';
    } else if (errorString.contains('not-found')) {
      return 'Nie znaleziono żądanych danych';
    } else if (errorString.contains('unauthenticated')) {
      return 'Musisz być zalogowany';
    } else if (errorString.contains('network-error') || errorString.contains('network')) {
      return 'Błąd połączenia sieciowego';
    } else if (errorString.contains('already-exists')) {
      return 'Rekord już istnieje';
    } else if (errorString.contains('FirebaseError')) {
      return 'Błąd bazy danych';
    }

    // Generic errors
    if (errorString.contains('Not authenticated')) {
      return 'Musisz być zalogowany';
    } else if (errorString.contains('Challenge not found')) {
      return 'Wyzwanie nie zostało znalezione';
    }

    return errorString;
  }
}