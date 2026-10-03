import 'package:material_ui/material_ui.dart';

import '../../../shared/components/header_text.dart';
import '../../../shared/components/profile_avatar_widget.dart';
import '../../../shared/constants.dart';
import '../../../shared/models/wiwit_api/profile/profile_response.dart';
import '../../profile/settings_page.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.profileDetail,
  });

  final String greeting;
  final ProfileResponse? profileDetail;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .stretch,
            children: [
              Text(greeting, style: TextStyle(fontSize: 14)),
              AnimatedSwitcher(
                duration: Durations.medium2,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  alignment: Alignment.centerLeft,
                  children: [...previousChildren, ?currentChild],
                ),
                child: AppBarText(
                  profileDetail?.name ?? '',
                  key: ValueKey(profileDetail),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: .end,
            children: [
              IconButton(
                onPressed: () {
                  if (profileDetail == null) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(userProfile: profileDetail!),
                    ),
                  );
                },
                tooltip: 'Settings',
                icon: Hero(
                  tag: kProfilePictureHeroTag,
                  child: ProfileAvatarWidget(profileDetail: profileDetail),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
