import 'package:chopper/chopper.dart';

import '../../constants.dart';
import '../../models/wiwit_api/instance/instance_response.dart';
import '../apis/instance_service.dart';
import '../../utils/server_url_utils.dart';
import 'json_serializable_converter.dart';

const _probeTimeout = Duration(seconds: 10);

/// Why [resolveServerUrl] couldn't return a usable server.
enum ServerProbeError {
  /// No candidate URL responded at all.
  unreachable,

  /// A candidate responded, but it isn't a Wiwit instance.
  notWiwitInstance,
}

class ResolveServerUrlResult {
  final String? url;
  final InstanceResponse? instance;
  final ServerProbeError? error;

  const ResolveServerUrlResult._({this.url, this.instance, this.error});

  const ResolveServerUrlResult.success(String url, InstanceResponse instance)
    : this._(url: url, instance: instance);

  const ResolveServerUrlResult.failure(ServerProbeError error)
    : this._(error: error);

  bool get isSuccess => url != null;
}

/// Determine to connect using https or http (https will be priority)
Future<ResolveServerUrlResult> resolveServerUrl(String raw) async {
  final candidates = serverUrlCandidates(raw);
  final instances = await Future.wait(candidates.map(_probeInstance));

  // Candidates come back most preferred first, so the first Wiwit hit wins.
  for (var i = 0; i < candidates.length; i++) {
    final instance = instances[i];
    if (instance != null && instance.application == kWiwitServerIdentifier) {
      return ResolveServerUrlResult.success(candidates[i], instance);
    }
  }

  final reachedSomething = instances.any((instance) => instance != null);
  return ResolveServerUrlResult.failure(
    reachedSomething
        ? ServerProbeError.notWiwitInstance
        : ServerProbeError.unreachable,
  );
}

Future<InstanceResponse?> _probeInstance(String baseUrl) async {
  final client = ChopperClient(
    baseUrl: Uri.parse(baseUrl),
    converter: JsonSerializableConverter({
      InstanceResponse: InstanceResponse.fromJson,
    }),
  );

  try {
    return await InstanceService.create(
      client,
    ).getInstance().timeout(_probeTimeout);
  } catch (_) {
    return null;
  } finally {
    client.dispose();
  }
}
