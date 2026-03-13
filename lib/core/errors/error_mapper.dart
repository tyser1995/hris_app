import 'package:postgrest/postgrest.dart';

import 'app_exception.dart';

/// Maps raw exceptions from Supabase / Postgrest / network into the
/// appropriate [AppException] subtype so that every catch block in the
/// service layer uses consistent, user-friendly error types.
class ErrorMapper {
  ErrorMapper._();

  /// General-purpose mapper used by every service fetch/write method.
  ///
  /// - Already-mapped [AppException]s pass through unchanged.
  /// - [PostgrestException]s are dispatched by their Postgres/PostgREST code.
  /// - Network-looking errors become [NetworkException].
  /// - Everything else becomes [AppException] with [fallbackMessage].
  static AppException map(Object error, String fallbackMessage) {
    if (error is AppException) return error;
    if (error is PostgrestException) {
      return _fromPostgrest(error, fallbackMessage);
    }
    if (_isNetworkError(error)) {
      return NetworkException(
        'No internet connection. Please check your network.',
        code: 'network_error',
      );
    }
    return AppException(fallbackMessage, details: error);
  }

  /// Auth-specific mapper for sign-in / password flows.
  ///
  /// Network errors still surface as [NetworkException]; everything else
  /// becomes [HrisAuthException] so the login screen can react appropriately.
  static AppException mapAuth(Object error) {
    if (error is AppException) return error;
    if (_isNetworkError(error)) {
      return NetworkException(
        'No internet connection. Please check your network.',
        code: 'network_error',
      );
    }
    return HrisAuthException(
      'Login failed. Please check your credentials.',
      code: 'auth_error',
    );
  }

  // ─── Postgrest error code mapping ──────────────────────────────────────────

  static AppException _fromPostgrest(
      PostgrestException e, String fallbackMessage) {
    switch (e.code) {
      // Row-level security / insufficient privilege
      case '42501':
        return PermissionException(
          'You do not have permission to perform this action.',
          code: e.code,
        );

      // PostgREST: expected one row, found zero
      case 'PGRST116':
        return NotFoundException(
          'The requested record was not found.',
          code: e.code,
        );

      // Unique constraint violation
      case '23505':
        return AppException(
          'A record with this information already exists.',
          code: e.code,
          details: e,
        );

      // Foreign key violation (delete/update blocked by related rows)
      case '23503':
        return AppException(
          'This record is linked to other data and cannot be removed.',
          code: e.code,
          details: e,
        );

      // Not-null constraint violation
      case '23502':
        return AppException(
          'Required information is missing.',
          code: e.code,
          details: e,
        );

      // Undefined table — likely a misconfiguration
      case '42P01':
        return AppException(
          'A required resource is unavailable. Please contact support.',
          code: e.code,
          details: e,
        );

      // JWT expired or invalid (PostgREST auth error)
      case 'PGRST301':
        return HrisAuthException(
          'Your session has expired. Please sign in again.',
          code: e.code,
        );

      default:
        return AppException(fallbackMessage, code: e.code, details: e);
    }
  }

  // ─── Network heuristic (works on web + mobile without dart:io) ─────────────

  static bool _isNetworkError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection refused') ||
        msg.contains('network is unreachable') ||
        msg.contains('no address associated with hostname') ||
        msg.contains('connection timed out') ||
        msg.contains('clientexception') ||
        msg.contains('handshake error');
  }
}
