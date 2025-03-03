import 'package:cloud_firestore/cloud_firestore.dart'; // للوصول إلى Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/Home_page.dart';

class PhoneAuthPage extends StatefulWidget {
  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  bool _isEmailVerified = false;
  bool _isLoading = false;
  int _verificationAttempts = 0;
  final int _maxAttempts = 3;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  // التحقق من حالة البريد الإلكتروني
  Future<void> _checkEmailVerification() async {
    // تحديد عدد المحاولات كحد أقصى
    if (_verificationAttempts >= _maxAttempts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لقد تجاوزت الحد الأقصى من المحاولات. الرجاء المحاولة لاحقًا.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // تأخير للسماح للمستخدم بالتحقق من البريد
    await Future.delayed(Duration(seconds: 10)); // يمكنك تغيير الزمن حسب الحاجة

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // تحديث حالة المستخدم من Firebase

    if (user != null && user.emailVerified) {
      // إذا تم التحقق من البريد الإلكتروني
      setState(() {
        _isEmailVerified = true;
        _isLoading = false;
      });

      // استرجاع الاسم الأول والأخير من Firestore
      final DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String firstName = userData['firstName'] ?? 'الاسم الأول';
      final String lastName = userData['lastName'] ?? 'الاسم الأخير';

      // الانتقال إلى الصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePage(firstName: firstName, lastName: lastName),
        ),
      );
    } else {
      // إذا لم يتم التحقق
      setState(() {
        _isLoading = false;
        _verificationAttempts++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لم يتم التحقق من البريد الإلكتروني بعد. حاول مرة أخرى.'),
        ),
      );
    }
  }

  // إرسال رسالة التحقق إذا لم يتم إرسالها بعد
  Future<void> _sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECE3DC),
      appBar: AppBar(
        title: Text('التحقق من البريد الإلكتروني'),
        backgroundColor: Color(0xFFECE3DC),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // تصحيح العنصر هنا
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isEmailVerified
                        ? 'تم التحقق من بريدك الإلكتروني! جاري نقلك إلى الصفحة الرئيسية...'
                        : 'تم إرسال رسالة التحقق إلى بريدك الإلكتروني. يرجى التحقق!',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (!_isEmailVerified)
                    ElevatedButton(
                      onPressed: _verificationAttempts < _maxAttempts
                          ? _checkEmailVerification
                          : null,
                      child: Text('التحقق مرة أخرى'),
                    ),
                ],
              ),
     ),
);
}
}
