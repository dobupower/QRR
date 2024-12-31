import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/point_management_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MemberInputScreen extends ConsumerStatefulWidget {
  @override
  _MemberInputScreenState createState() => _MemberInputScreenState();
}

class _MemberInputScreenState extends ConsumerState<MemberInputScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      ref.read(transactionProvider.notifier).updateUid(_controller.text, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.07),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                localizations?.meberInputScreenUserNumber1 ?? '',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: CircleAvatar(
                radius: screenWidth * 0.15,
                backgroundColor: Colors.blue.shade900,
                child: Text(
                  '鳥横',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Center(
              child: Text(
                localizations?.meberInputScreenUserNumber2 ?? '',
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Center(
              child: Text(
                _controller.text.isEmpty ? '0000-0000-0000' : _controller.text,
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Container(
              height: screenHeight * 0.35,
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 2,
                mainAxisSpacing: screenHeight * 0.002,
                crossAxisSpacing: screenWidth * 0.01,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(12, (index) {
                  String displayText;
                  if (index == 9) {
                    displayText = 'C';
                  } else if (index == 11) {
                    return IconButton(
                      icon: Icon(Icons.backspace, size: screenWidth * 0.07, color: Colors.black),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          setState(() {
                            _controller.text = _controller.text.substring(0, _controller.text.length - 1);
                          });
                        }
                      },
                    );
                  } else {
                    displayText = index == 10 ? '0' : '${index + 1}';
                  }

                  return GestureDetector(
                    onTap: () {
                      if (displayText == 'C') {
                        setState(() {
                          _controller.clear();
                        });
                      } else {
                        if (_controller.text.length < 14) {
                          setState(() {
                            if (_controller.text.length % 5 == 4 && _controller.text.length < 14) {
                              _controller.text += '-';
                            }
                            _controller.text += displayText;
                          });
                        }
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(screenWidth * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Center(
                        child: Text(
                          displayText,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final uid = _controller.text;
                  final exists = await ref.read(transactionProvider.notifier).verifyUserUid(uid);

                  if (exists) {
                    Navigator.pushNamed(context, '/pointManagement');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations?.meberInputScreenError ?? '')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1D2538),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.07),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.35,
                    vertical: screenHeight * 0.015,
                  ),
                ),
                child: Text(
                  localizations?.meberInputScreenSubmit ?? '',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white, // 글씨 색을 흰색으로 설정
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
