import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_saas_mobile/core/network/api_client.dart';

class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromString('{"ok":true}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('ApiClient injects Bearer token, X-Tenant-Domain, and X-Branch-Id headers',
      () async {
    final adapter = _CapturingAdapter();
    final client = ApiClient(
      baseUrl: 'http://demo.localhost:8001/api/v1',
      tokenReader: () => 'test-sanctum-token',
      tenantDomainReader: () => 'demo.localhost',
      branchIdReader: () => 42,
    );
    client.raw.httpClientAdapter = adapter;

    await client.raw.get<dynamic>('/inventory');

    final sent = adapter.lastOptions;
    expect(sent, isNotNull);
    expect(sent!.headers['Authorization'], 'Bearer test-sanctum-token');
    expect(sent.headers['X-Tenant-Domain'], 'demo.localhost');
    expect(sent.headers['X-Branch-Id'], '42');
    expect(sent.headers['Accept'], 'application/json');
  });
}
