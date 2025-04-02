import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/home_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  String? _passwordStrength;
  bool _isLoading = false;
  bool _isEmailVerified = false;

  // التحقق الدوري من البريد الإلكتروني
  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // تحديث حالة المستخدم من Firebase
    if (user != null && user.emailVerified) {
      setState(() {
        _isEmailVerified = true;
      });

      // جلب بيانات المستخدم من Firestore
      final DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String firstName = userData['firstName'] ?? 'الاسم الأول';
      final String lastName = userData['lastName'] ?? 'الاسم الأخير';

      // نقل المستخدم إلى الصفحة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePage(firstName: firstName, lastName: lastName),
        ),
      );
    } else {
      // إذا لم يتم التحقق، حاول مرة أخرى بعد 5 ثوانٍ
      Future.delayed(Duration(seconds: 5), _checkEmailVerification);
    }
  }

  // إنشاء الحساب
  Future<void> _createAccount() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // تخزين البيانات الإضافية في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
      });

      // إرسال رسالة تحقق بالبريد الإلكتروني
      await userCredential.user!.sendEmailVerification();

      // عرض رسالة للمستخدم
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني. يرجى التحقق.'),
        ),
      );

      // بدء التحقق الدوري من البريد الإلكتروني
      _checkEmailVerification();
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ أثناء إنشاء الحساب.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'البريد الإلكتروني مستخدم بالفعل.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // إخفاء وإظهار كلمة المرور
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 150),
                    Text(
                      'إنشاء حساب',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 68, 49, 31),
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 158, 170, 151),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 66, 62, 62),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: buildTextFieldWithLabel(
                                    'الإسم الأخير',
                                    TextInputType.name,
                                    _lastNameController,
                                    true,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: buildTextFieldWithLabel(
                                    'الاسم الأول',
                                    TextInputType.name,
                                    _firstNameController,
                                    true,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            buildFieldWithIcon(
                              'البريد الإلكتروني',
                              Icons.email,
                              _emailController,
                              'example@domain.com',
                              (value) {
                                if (value == null ||
                                    !RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                        .hasMatch(value)) {
                                  return 'يرجى إدخال بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            buildFieldWithIcon(
                              'اسم المستخدم',
                              Icons.person,
                              _usernameController,
                              'Username',
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال اسم المستخدم';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 15),
                            buildPasswordField('كلمة السر'),
                            if (_passwordStrength != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _passwordStrength!,
                                  style: TextStyle(
                                    color: _passwordStrength == 'قوية'
                                        ? const Color.fromARGB(255, 20, 87, 23)
                                        : (_passwordStrength == 'متوسطة'
                                            ? const Color.fromARGB(
                                                255, 155, 110, 20)
                                            : const Color.fromARGB(
                                                180, 221, 30, 16)),
                                  ),
                                ),
                              ),
                            SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        await _createAccount();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'يرجى تعبئة جميع الحقول بشكل صحيح.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      'إنشاء حساب',
                                      style: TextStyle(color: Colors.white),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 68, 49, 31),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                textStyle: TextStyle(fontSize: 18),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('لديك حساب بالفعل؟',
                                    style: TextStyle(color: Colors.black)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 19, 115, 12),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldWithIcon(
      String label,
      IconData icon,
      TextEditingController controller,
      String hintText,
      String? Function(String?)? validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.brown,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.brown),
            border: UnderlineInputBorder(),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget buildPasswordField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.brown,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscureText,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.brown,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });

                // إضافة تأخير لإخفاء كلمة السر بعد مدة قصيرة
                if (!_obscureText) {
                  Future.delayed(Duration(seconds: 1), () {
                    setState(() {
                      _obscureText = true; // إخفاء كلمة السر بعد 2 ثانية
                    });
                  });
                }
              },
            ),
            border: UnderlineInputBorder(),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة السر';
            }
            if (value.length < 8) {
              return 'يجب أن تكون كلمة السر مكونة من 8 أحرف على الأقل';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              bool hasUpperCase = value.contains(RegExp(r'[A-Z]'));
              bool hasLowerCase = value.contains(RegExp(r'[a-z]'));
              bool hasDigits = value.contains(RegExp(r'[0-9]'));
              bool hasSpecialCharacters =
                  value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

              if (value.length >= 8 &&
                  hasUpperCase &&
                  hasLowerCase &&
                  hasDigits &&
                  hasSpecialCharacters) {
                _passwordStrength = 'قوية';
              } else if (value.length >= 8 && hasUpperCase && hasLowerCase) {
                _passwordStrength = 'متوسطة';
              } else {
                _passwordStrength = 'ضعيفة';
              }
            });
          },
        ),
      ],
    );
  }

  Widget buildTextFieldWithLabel(String label, TextInputType inputType,
      TextEditingController controller, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.brown,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'يرجى إدخال $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
