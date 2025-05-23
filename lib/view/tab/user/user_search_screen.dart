import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/user_point_uid_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserSearchScreen extends ConsumerStatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userPointsUidProvider).userState;

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: screenWidth * 0.06,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations?.userSearchScreenTitle ?? '',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(userPointsUidProvider.notifier).searchUserByNameOrUid(value);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey, size: screenWidth * 0.06),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.highlight_off, color: Colors.grey, size: screenWidth * 0.05),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(userPointsUidProvider.notifier).searchUserByNameOrUid('');
                      },
                    ),
                    hintText: localizations?.userSearchScreenSearchHint ?? '',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.08),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: userState.when(
                data: (users) {
                  if (users.isEmpty) {
                    return Center(child: Text(localizations?.userSearchScreenSearchSnackbar ?? ''));
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              ref.read(userPointsUidProvider.notifier).updateUserByUid(user.uid);
                              Navigator.pushNamed(
                                context,
                                '/userTransfer',
                                arguments: user,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: screenHeight * 0.015,
                                  bottom: screenHeight * 0.007),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: screenWidth * 0.07,
                                    backgroundColor: Colors.grey,
                                    foregroundImage: user.profilePicUrl != null
                                        ? NetworkImage(user.profilePicUrl!)
                                        : null,
                                    child: user.profilePicUrl == null
                                        ? Icon(Icons.person,
                                            size: screenWidth * 0.06, color: Colors.white)
                                        : null,
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            user.name,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.05,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: screenHeight * 0.01),
                                            child: Text(
                                              user.uid,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                            height: screenHeight * 0.002,
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(child: Text(localizations?.ownerAccountScreenError ?? '' + ': $error')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
