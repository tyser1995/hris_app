import 'package:flutter_test/flutter_test.dart';
import 'package:hris_app/core/errors/app_exception.dart';
import 'package:hris_app/core/errors/error_mapper.dart';
import 'package:postgrest/postgrest.dart';

void main() {
  group('ErrorMapper.map', () {
    test('passes through AppException unchanged', () {
      const input = AppException('already mapped');
      final result = ErrorMapper.map(input, 'fallback');
      expect(result, same(input));
    });

    test('passes through AppException subclass unchanged', () {
      const input = PermissionException('no perms');
      final result = ErrorMapper.map(input, 'fallback');
      expect(result, same(input));
    });

    test('maps PostgrestException 42501 → PermissionException', () {
      final e = PostgrestException(message: 'rls', code: '42501');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result, isA<PermissionException>());
      expect(result.message,
          contains('You do not have permission'));
    });

    test('maps PostgrestException PGRST116 → NotFoundException', () {
      final e = PostgrestException(message: 'no rows', code: 'PGRST116');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result, isA<NotFoundException>());
      expect(result.message, contains('not found'));
    });

    test('maps PostgrestException 23505 → AppException (duplicate)', () {
      final e = PostgrestException(message: 'unique', code: '23505');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result, isA<AppException>());
      expect(result.message, contains('already exists'));
    });

    test('maps PostgrestException 23503 → AppException (fk)', () {
      final e = PostgrestException(message: 'fk', code: '23503');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result.message, contains('linked to other data'));
    });

    test('maps PostgrestException 23502 → AppException (not-null)', () {
      final e = PostgrestException(message: 'null', code: '23502');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result.message, contains('Required information is missing'));
    });

    test('maps PostgrestException 42P01 → AppException (missing table)', () {
      final e = PostgrestException(message: 'no table', code: '42P01');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result.message, contains('unavailable'));
    });

    test('maps PostgrestException PGRST301 → HrisAuthException (jwt expired)',
        () {
      final e = PostgrestException(message: 'jwt', code: 'PGRST301');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result, isA<HrisAuthException>());
      expect(result.message, contains('session has expired'));
    });

    test('maps unknown PostgrestException → AppException with fallback message',
        () {
      final e = PostgrestException(message: 'unknown', code: '99999');
      final result = ErrorMapper.map(e, 'custom fallback');
      expect(result, isA<AppException>());
      expect(result.message, equals('custom fallback'));
      expect(result.code, equals('99999'));
    });

    test('maps network-looking error → NetworkException', () {
      final e = Exception('SocketException: connection refused');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result, isA<NetworkException>());
      expect(result.message, contains('No internet connection'));
    });

    test('maps ClientException → NetworkException', () {
      final e = Exception('ClientException: handshake error');
      final result = ErrorMapper.map(e, 'fallback');
      expect(result, isA<NetworkException>());
    });

    test('maps unknown error → AppException with fallback', () {
      final e = Exception('something random');
      final result = ErrorMapper.map(e, 'my fallback');
      expect(result, isA<AppException>());
      expect(result.message, equals('my fallback'));
    });
  });

  group('ErrorMapper.mapAuth', () {
    test('passes through AppException unchanged', () {
      const input = HrisAuthException('already auth');
      final result = ErrorMapper.mapAuth(input);
      expect(result, same(input));
    });

    test('maps network error → NetworkException', () {
      final e = Exception('failed host lookup: supabase.co');
      final result = ErrorMapper.mapAuth(e);
      expect(result, isA<NetworkException>());
    });

    test('maps generic error → HrisAuthException', () {
      final e = Exception('invalid credentials');
      final result = ErrorMapper.mapAuth(e);
      expect(result, isA<HrisAuthException>());
      expect(result.message, contains('Login failed'));
    });
  });

  group('AppException.toString', () {
    test('returns message only', () {
      const e = AppException('Something went wrong', code: 'E001');
      expect(e.toString(), equals('Something went wrong'));
    });

    test('subclasses convert correctly', () {
      const e = PermissionException('Denied');
      expect(e.toString(), equals('Denied'));
    });
  });
}
