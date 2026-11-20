import '../models/wiwit_api/tags/tag_response.dart';
import '../services/apis/tag_service.dart';

extension TagServiceAllPages on TagService {
  static const _perPage = 100;

  /// Fetches every page of tags, sorted by name.
  Future<List<TagResponse>> getAllTags() async {
    final tags = <TagResponse>[];

    for (var page = 1; ; page++) {
      final response = await getTags(page: page, perPage: _perPage);
      tags.addAll(response.data);

      if (page >= response.meta.lastPage) break;
    }

    tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return tags;
  }
}
