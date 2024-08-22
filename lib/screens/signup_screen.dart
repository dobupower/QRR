import 'package:flutter/material.dart';

// SignUpScreen 클래스는 StatefulWidget을 상속받아 상태가 있는 위젯을 정의합니다.
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

// _SignUpScreenState 클래스는 SignUpScreen의 상태를 관리합니다.
class _SignUpScreenState extends State<SignUpScreen> {
  // 스크롤 동작을 제어하기 위한 ScrollController
  final ScrollController _scrollController = ScrollController();
  
  // 각 입력 필드의 포커스를 관리하기 위한 FocusNode
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // 비밀번호와 비밀번호 확인 필드의 가시성 상태를 관리
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    // FocusNode에 리스너를 추가하여 포커스가 변경될 때 스크롤을 이동
    _nameFocusNode.addListener(() => _scrollToFocus(_nameFocusNode));
    _emailFocusNode.addListener(() => _scrollToFocus(_emailFocusNode));
    _passwordFocusNode.addListener(() => _scrollToFocus(_passwordFocusNode));
    _confirmPasswordFocusNode.addListener(() => _scrollToFocus(_confirmPasswordFocusNode));
  }

  // 포커스된 입력 필드가 화면에 보이도록 스크롤하는 함수
  void _scrollToFocus(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면의 가로 및 세로 크기를 가져옴
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        return Scaffold(
          // 앱바 설정
          appBar: AppBar(
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                // 뒤로 가기 버튼 클릭 시 동작을 정의
              },
            ),
            backgroundColor: Colors.transparent, // 앱바의 배경색을 투명하게 설정
            elevation: 0, // 앱바의 그림자 제거
          ),
          body: SingleChildScrollView(
            controller: _scrollController, // 스크롤 컨트롤러 지정
            padding: EdgeInsets.all(16.0), // 화면 가장자리의 여백 설정
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 중앙에 배치된 제목 텍스트
                  Center(
                    child: Text(
                      '会員登録', // '회원가입'이라는 제목
                      style: TextStyle(
                        fontSize: width * 0.06, // 폰트 크기
                        fontWeight: FontWeight.bold, // 글씨 두께
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02), // 요소 간 간격

                  // 이름 입력 필드 생성
                  _buildTextField('表示名', 'あかばね', width, height, _nameFocusNode),
                  SizedBox(height: height * 0.02), // 요소 간 간격

                  // 이메일 입력 필드 생성
                  _buildTextField('メールアドレス', 'Enter your email', width, height, _emailFocusNode),
                  SizedBox(height: height * 0.02), // 요소 간 간격

                  // 비밀번호 입력 필드 생성
                  _buildPasswordField('パスワード', '*********', width, height, _passwordFocusNode, true),
                  SizedBox(height: height * 0.02), // 요소 간 간격

                  // 비밀번호 확인 입력 필드 생성
                  _buildPasswordField('パスワード確認', '*********', width, height, _confirmPasswordFocusNode, true),
                  SizedBox(height: height * 0.1), // 요소 간 간격

                  // 회원가입 버튼
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // 회원가입 로직을 여기에 작성
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1D2538), // 버튼 배경색
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.3, // 버튼의 가로 패딩
                          vertical: height * 0.01, // 버튼의 세로 패딩
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50), // 버튼의 모서리 둥글기
                        ),
                      ),
                      child: Text(
                        'アカウント作成', // '계정 생성'이라는 버튼 텍스트
                        style: TextStyle(
                          fontSize: width * 0.045, // 텍스트의 폰트 크기
                          color: Colors.white, // 텍스트 색상
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02), // 요소 간 간격

                  // 이용 약관 및 개인정보 처리방침 안내 텍스트
                  Center(
                    child: Text(
                      'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。',
                      textAlign: TextAlign.center, // 텍스트 정렬
                      style: TextStyle(
                        fontSize: width * 0.03, // 폰트 크기
                        color: Colors.black, // 텍스트 색상
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 일반 텍스트 입력 필드를 생성하는 함수
  Widget _buildTextField(String label, String hint, double width, double height, FocusNode focusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레이블 텍스트
        Text(
          label,
          style: TextStyle(fontSize: width * 0.05), // 레이블의 폰트 크기
        ),
        SizedBox(height: height * 0.01), // 요소 간 간격

        // 입력 필드 위젯
        TextFormField(
          focusNode: focusNode, // FocusNode 지정
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0), // 입력 필드의 모서리 둥글기
              borderSide: BorderSide(
                color: Colors.grey, // 입력 필드의 테두리 색상
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey[300]!, // 비활성화된 입력 필드의 테두리 색상
                width: 1.5, // 비활성화된 입력 필드의 테두리 두께
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey, // 활성화된 입력 필드의 테두리 색상
                width: 2.0, // 활성화된 입력 필드의 테두리 두께
              ),
            ),
            hintText: hint, // 힌트 텍스트
            hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 스타일
          ),
        ),
      ],
    );
  }

  // 비밀번호 입력 필드를 생성하는 함수
  Widget _buildPasswordField(String label, String hint, double width, double height, FocusNode focusNode, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 레이블 텍스트
        Text(
          label,
          style: TextStyle(fontSize: width * 0.05), // 레이블의 폰트 크기
        ),
        SizedBox(height: height * 0.01), // 요소 간 간격

        // 비밀번호 입력 필드 위젯
        TextFormField(
          focusNode: focusNode, // FocusNode 지정
          obscureText: isPassword
              ? (label == 'パスワード' ? !_isPasswordVisible : !_isConfirmPasswordVisible)
              : false, // 비밀번호 가리기 여부
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0), // 입력 필드의 모서리 둥글기
              borderSide: BorderSide(
                color: Colors.grey, // 입력 필드의 테두리 색상
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey[300]!, // 비활성화된 입력 필드의 테두리 색상
                width: 1.5, // 비활성화된 입력 필드의 테두리 두께
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey, // 활성화된 입력 필드의 테두리 색상
                width: 2.0, // 활성화된 입력 필드의 테두리 두께
              ),
            ),
            hintText: hint, // 힌트 텍스트
            hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 스타일
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (label == 'パスワード' ? _isPasswordVisible : _isConfirmPasswordVisible)
                          ? Icons.visibility // 비밀번호 보이기 아이콘
                          : Icons.visibility_off, // 비밀번호 숨기기 아이콘
                    ),
                    onPressed: () {
                      setState(() {
                        // 비밀번호 가시성 상태를 토글
                        if (label == 'パスワード') {
                          _isPasswordVisible = !_isPasswordVisible;
                        } else {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        }
                      });
                    },
                  )
                : null, // 비밀번호 필드가 아닐 경우 아이콘 없음
          ),
        ),
      ],
    );
  }
}
