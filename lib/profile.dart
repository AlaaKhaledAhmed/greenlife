import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/widget/AppSize.dart';
import 'package:greenlife/widget/AppText.dart';
import 'package:greenlife/widget/showDialog.dart';
import 'package:greenlife/widget/utils.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginDialog();
    } else {
      _loadUserData(user);
    }
  }

  Future<void> _loadUserData(User user) async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      _firstNameController.text = userData['firstName'] ?? '';
      _lastNameController.text = userData['lastName'] ?? '';
      _usernameController.text = userData['username'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _passwordController.text = userData['password'];
    });
  }

  void _showLoginDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAlert(
          context: context,
          title: 'تنبيه',
          content: 'يجب عليك تسجيل الدخول أولًا للوصول إلى ملفك الشخصي.',
          buttonsText: 'موافق',
          showButton: true,
          onConfirm: () {
            Navigator.of(context).pop();
          });
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                Utils.imagesBack,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                    padding: EdgeInsets.only(
                        bottom: 15,
                        top: MediaQuery.of(context).padding.top + 10),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: ListTile(
                      title: AppText(
                        text: 'الملف الشخصي',
                        fontSize: AppSize.labelSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
              ),
              SizedBox(
                height: 100,
              ),
              Form(
                key: _formKey,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
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
                      buildTextFieldWithLabel('اسم المستخدم',
                          TextInputType.text, _usernameController, true),
                      SizedBox(height: 15),
                      buildTextFieldWithLabel('البريد الإلكتروني',
                          TextInputType.emailAddress, _emailController, false),
                      SizedBox(height: 15),
                      buildPasswordField('كلمة السر'),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  await _updateProfile();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 68, 49, 31),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'تحديث الملف الشخصي',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldWithLabel(String label, TextInputType inputType,
      TextEditingController controller, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.brown, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          textAlign: TextAlign.right,
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

  Widget buildPasswordField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.brown, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscureText,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            prefixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

//update function====================================================================================
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          // **1️⃣ جلب البريد الإلكتروني وكلمة المرور القديمة من Firestore**
          DocumentSnapshot userData = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          String oldEmail = userData['email'];
          String oldPass =
              userData['password']; // 🔹 تأكد من أن كلمة المرور مخزنة هنا

          // **2️⃣ إعادة المصادقة قبل تحديث البيانات**
          AuthCredential credential = EmailAuthProvider.credential(
            email: oldEmail,
            password: oldPass, // تأكد من أن هذه كلمة المرور القديمة الصحيحة
          );

          await user.reauthenticateWithCredential(credential);

          // **3️⃣ تحديث البريد الإلكتروني إذا تغيّر**
          if (_emailController.text.isNotEmpty &&
              _emailController.text != oldEmail) {
            await user.updateEmail(_emailController.text);
          }

          // **4️⃣ تحديث كلمة المرور فقط إذا تغيّرت**
          if (_passwordController.text.isNotEmpty &&
              _passwordController.text != oldPass) {
            await user.updatePassword(_passwordController.text);
          }

          // **5️⃣ تحديث البيانات في Firestore**
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'username': _usernameController.text,
            'email': _emailController.text,
            'password': _passwordController.text, // تحديث كلمة المرور أيضًا
          });

          // **6️⃣ إظهار رسالة نجاح**
          showAlert(
              context: context,
              title: 'الملف الشخصي',
              content: 'تم تحديث البيانات بنجاح!',
              buttonsText: 'موافق',
              showButton: true,
              onConfirm: () {
                Navigator.of(context).pop();
              });
        } catch (e) {
          showAlert(
              context: context,
              title: 'خطأ',
              content: 'حدث خطأ أثناء التحديث: ${e.toString()}',
              buttonsText: 'موافق',
              showButton: true,
              onConfirm: () {
                Navigator.of(context).pop();
              });
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
