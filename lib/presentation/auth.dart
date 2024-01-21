
import 'package:eurisco_tv_box/data/implements/hive_implementation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';
import '../data/implements/server_implementation.dart';
import 'main_box.dart';

class ActionIntent extends Intent {}


class Auth extends ConsumerStatefulWidget {
  const Auth({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthState();
}

class _AuthState extends ConsumerState<Auth> {

  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    HiveImpl().saveClient('');
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final messenger = ScaffoldMessenger.of(context);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select) : const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActionIntent: CallbackAction(onInvoke: (Intent i) => null), 
        },
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: ProgressHUD(
              barrierColor: Colors.white.withOpacity(0.7),
              padding: const EdgeInsets.all(20.0),
              child: Builder(
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        opacity: 0.7,
                        image: AssetImage('lib/images/background.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                                    
                        const SizedBox(height: 40,),
                        Opacity(
                          opacity: 0.7,
                          child: Image.asset('lib/images/eurisco_tv.png', scale: 2)
                        ),
                        const SizedBox(height: 20,),
                        Text('для подключения устройства введите PIN код', style: GoogleFonts.montserrat(color: firmColor.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 10,),
                                    
                        PinCodeFields(
                          obscureCharacter: '∗',
                          obscureText: true,
                          margin: const EdgeInsets.all(0.0),
                          autofocus: false,
                          length: 4,
                          fieldBorderStyle: FieldBorderStyle.square,
                          responsive: false,
                          fieldHeight: 80.0,
                          fieldWidth: 80.0,
                          borderWidth: 2.0,
                          activeBorderColor: firmColor,
                          activeBackgroundColor: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10.0),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          autoHideKeyboard: true,
                          fieldBackgroundColor: Colors.white.withOpacity(0.5),
                          borderColor: const Color(0xFF7d97af).withOpacity(0.6),
                          textStyle: firm50,
                          onComplete: (String value) async {
                            final progress = ProgressHUD.of(context);
                            progress?.showWithText('проверка...');
                            ServerImpl().connectDevice(value).then((result) {
                              messenger._toast(result);
                              progress?.dismiss();
                              result == 'failed' ? {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Auth()))
                              } : {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainBox()))
                              };
                            });
                          },
                        ),
                                    
                        const SizedBox(height: 20,),
                        Opacity(opacity: 0.8, child: Text('Все права зашищены©. ООО ЭВРИСКО, 2023', style: firm10,)),
                        const SizedBox(height: 20,),
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../colors.dart';
import '../data/implements/server_implementation.dart';
import '../data/providers.dart';
import 'android_main.dart';


class ActionIntent extends Intent {}

class AuthAndroid extends ConsumerStatefulWidget {
  const AuthAndroid({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AndroidAuthState();
}

class _AndroidAuthState extends ConsumerState<AuthAndroid> {

  TextEditingController loginController = TextEditingController();
  TextEditingController passController = TextEditingController();
  final FocusNode _loginFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    loginController.clear();
    passController.clear();
    loginController.dispose();
    passController.dispose();
    _loginFocusNode.dispose();
    _passFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {


    final focusIndex = ref.watch(onFocusIndexProvider);
    final messenger = ScaffoldMessenger.of(context);


    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select) : const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActionIntent: CallbackAction(onInvoke: (Intent i) => null), 
        },
        child: WillPopScope(
          onWillPop: () async {
            // FocusScope.of(context).unfocus();
            _loginFocusNode.unfocus();
            _passFocusNode.unfocus();
            ref.read(onFocusIndexProvider.notifier).state = 9999;
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: ProgressHUD(
              barrierColor: Colors.white.withOpacity(0.7),
              padding: const EdgeInsets.all(20.0),
              child: Builder(
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        opacity: 0.7,
                        image: AssetImage('lib/images/background.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 30,),
                        // Image.asset('lib/images/logo2.png', scale: 3),
                        Image.asset('lib/images/eurisco_tv.png', scale: 3),
                        const SizedBox(height: 25,),
                        
                        
                        // поле ввода логина
                        InkWell(
                          onFocusChange: (bool isFocused){
                            isFocused ? ref.read(onFocusIndexProvider.notifier).state = 1 : null;
                          },
                          onTap: (){ FocusScope.of(context).requestFocus(_loginFocusNode); },
                          child: Container(
                            height: 40,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: focusIndex == 1 ? const Color(0xFF687797) : Colors.transparent
                              ),
                              color: Colors.blue.shade100.withOpacity(0.4),
                            ),
                            child: TextField(
                              controller: loginController,
                              focusNode: _loginFocusNode,
                              style: firm18,
                              minLines: 1,
                              obscureText: false,
                              textAlignVertical: TextAlignVertical.bottom,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // contentPadding: const EdgeInsets.all(10.0),
                                contentPadding: const EdgeInsets.only(bottom: 8),
                                hintStyle: grey14,
                                hintText: 'ID клиента',
                                prefixIcon: const IconTheme(data: IconThemeData(color: Color(0xFF687797)), child: Icon(Icons.person)),
                                isCollapsed: true
                              ),
                              onSubmitted: (_) { 
                                ref.read(onFocusIndexProvider.notifier).state = 9999;
                                _loginFocusNode.unfocus();
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // поле ввода пароля
                        InkWell(
                          onFocusChange: (bool isFocused){
                            isFocused ? ref.read(onFocusIndexProvider.notifier).state = 2 : null;
                          },
                          onTap: (){ FocusScope.of(context).requestFocus(_passFocusNode); },
                          child: Container(
                            height: 40,
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: focusIndex == 2 ? const Color(0xFF687797) : Colors.transparent
                              ),
                              color: Colors.blue.shade100.withOpacity(0.4),
                            ),
                            child: TextField(
                              controller: passController,
                              focusNode: _passFocusNode,
                              style: firm18,
                              minLines: 1,
                              obscureText: true,
                              textAlignVertical: TextAlignVertical.bottom,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                // contentPadding: const EdgeInsets.all(10.0),
                                contentPadding: const EdgeInsets.only(bottom: 8),
                                hintStyle: grey14,
                                hintText: 'пароль',
                                prefixIcon: const IconTheme(data: IconThemeData(color: Color(0xFF687797)), child: Icon(Icons.lock)),
                                isCollapsed: true
                              ),
                              onSubmitted: (_) { 
                                ref.read(onFocusIndexProvider.notifier).state = 9999;
                                _passFocusNode.unfocus();
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
            
                        // кнопка входа
                        loginController.text.isEmpty || passController.text.isEmpty ? const SizedBox.shrink() :
                        InkWell(
                          onFocusChange: (bool isFocused){
                            isFocused ? ref.read(onFocusIndexProvider.notifier).state = 3 : null;
                          },
                          onTap: () async { 
                            ref.read(onFocusIndexProvider.notifier).state = 9999;
                            Map authData = {'login': loginController.text.toString(), 'password': passController.text.toString()};
                            FocusScope.of(context).unfocus();
                            final progress = ProgressHUD.of(context);
                            progress?.showWithText('проверка...');
                            await ServerImpl().auth(authData).then((value) {
                              progress?.dismiss();
                                  value == 'no connection' ? messenger._toast('отсутствует соединение с сервером') : 
                                    value == 'admitted' ? {
                                      ref.read(onFocusIndexProvider.notifier).state = 9999,
                                      loginController.clear(), 
                                      passController.clear(), 
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AndroidMain()))
                                    } : { 
                                      ref.read(onFocusIndexProvider.notifier).state = 9999,
                                      messenger._toast('доступ запрещен'),
                                    };
                            });
                          },
                          child: Container(
                            height: 35,
                            width: 250,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: focusIndex == 3 ? Colors.black.withOpacity(0.8) : Colors.grey.withOpacity(0.7),
                                  spreadRadius: 0.5,
                                  blurRadius: 2,
                                  offset: const Offset(0, 2), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(5),
                              color: focusIndex == 3 ? const Color(0xFF687797) : const Color(0xFF96A0B7),
                            ),
                            child: Center(child: Text('вход', style: white14))
                          ),
                        ),

                        const SizedBox(height: 20),
                        Center(child: Text('Все права зашищены©. ООО ЭВРИСКО, 2023.', style: firm10,)),
                        const SizedBox(height: 20),
            
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        )
      )
    );
  }
}
*/

extension on ScaffoldMessengerState {
  void _toast(String message){
    showSnackBar(
      SnackBar(
        content: Text(message), 
        duration: const Duration(seconds: 4),
      )
    );
  }
}