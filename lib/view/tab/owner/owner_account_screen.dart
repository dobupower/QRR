import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/owner_account_view_model.dart';
import '../../../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnerAccountScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 병합된 상태를 Provider에서 직접 가져오기
    final combinedState = ref.watch(ownerAccountProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: combinedState.when(
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(AppLocalizations.of(context)?.ownerAccountScreenError ?? '' + ': $error')), // 에러 상태
          data: (data) {
            final owner = data['owner']; // Owner 데이터
            final pubInfo = data['pubInfo']; // PubInfo 데이터
            return Column(
              children: [
                _buildProfileSection(owner, pubInfo, screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.15), // 프로필 섹션 아래 여백
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailsSection(context, owner, screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.01),
                        Divider(thickness: screenHeight * 0.001, color: Colors.grey[300]),
                        SizedBox(height: screenHeight * 0.01),
                        _buildPasswordChangeSection(context, owner, screenWidth, screenHeight),
                        Divider(thickness: screenHeight * 0.001, color: Colors.grey[300]),
                        _buildStorePhotoSettingSection(context, screenWidth, screenHeight),
                        Divider(thickness: screenHeight * 0.001, color: Colors.grey[300]),
                      ],
                    ),
                  ),
                ),
                _buildLogoutButton(context, ref, screenWidth, screenHeight),
              ],
            );
          },
        ),
      ),
    );
  }

  // 프로필 섹션
  Widget _buildProfileSection(dynamic owner, dynamic pubInfo, double screenWidth, double screenHeight) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: screenHeight * 0.3,
          color: const Color(0xFFE3E8EF), // 배경색 설정
        ),
        Positioned(
          bottom: -(screenHeight * 0.1),
          left: (screenWidth - screenHeight * 0.2) / 2,
          child: Column(
            children: [
              CircleAvatar(
                radius: screenHeight * 0.1,
                backgroundColor: const Color(0xFF4A6FA5),
                backgroundImage: pubInfo.logoUrl != null
                    ? NetworkImage(pubInfo.logoUrl!) // logoUrl에서 이미지 가져오기
                    : null,
                child: pubInfo.logoUrl == null
                    ? Icon(
                        Icons.store, // 기본 아이콘 변경
                        size: screenHeight * 0.08,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                owner.storeName,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

 // 상세 정보 섹션
  Widget _buildDetailsSection(BuildContext context, dynamic owner, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/SignupUpdate'); // 매장 선택 화면 이동
          },
          child: _buildInfoRow(
            title: '${owner.storeName ?? localizations?.ownerAccountScreenNull ?? ''}@${owner.address ?? ''}', // storeName과 address 결합
            value: '',
            isLongText: true,
            screenWidth: screenWidth,
            showIcon: true,
          ),
        ),
        _buildInfoRow(
          title: localizations?.ownerSignUpScreenEmail1 ?? '',
          value: owner.email,
          isLongText: true,
          screenWidth: screenWidth,
          showIcon: false,
        ),
      ],
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow({
    required String title,
    required String value,
    required bool isLongText,
    required double screenWidth,
    required bool showIcon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.04,
            color: const Color.fromARGB(255, 145, 163, 189),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.05),
              child: isLongText && value.length > 20
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: value.substring(0, 18)),
                          TextSpan(text: '\n${value.substring(18)}'),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        if (showIcon)
          Icon(
            Icons.arrow_forward_ios,
            size: screenWidth * 0.04,
            color: Colors.grey,
          ),
      ],
    );
  }

  // 비밀번호 변경 섹션
  Widget _buildPasswordChangeSection(BuildContext context, dynamic owner, double screenWidth, double screenHeight) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.pushNamed(context, '/verifyPassword');
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)?.ownerAccountScreenPasswordChange ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // 店舗写真設定 섹션 추가
  Widget _buildStorePhotoSettingSection(BuildContext context, double screenWidth, double screenHeight) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.pushNamed(context, '/photoUpdate'); // 매장 사진 설정 화면 이동
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)?.ownerAccountScreenPhotoChange ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.04,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // 로그아웃 버튼
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      child: OutlinedButton(
        onPressed: () async {
          final authService = AuthService();
          await authService.logout(context, ref); // 로그아웃 처리
          Navigator.of(context, rootNavigator: true).pushReplacementNamed('/first'); // 첫 화면으로 이동
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.black,
            width: screenWidth * 0.005,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.1),
          ),
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
          ),
          minimumSize: Size(screenWidth, screenHeight * 0.05),
        ),
        child: Text(
          AppLocalizations.of(context)?.ownerAccountScreenLogout ?? '',
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}