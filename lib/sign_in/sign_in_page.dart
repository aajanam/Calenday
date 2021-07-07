import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jadwalku/helper/platform_exception_alert_dialog.dart';
import 'package:jadwalku/services/auth.dart';
import 'package:jadwalku/sign_in/sign_in_bloc.dart';
import 'package:jadwalku/widget/social_sign_in_button.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, @required this.bloc, @required this.isLoading})
      : super(key: key);
  final SignInBloc bloc;
  final bool isLoading;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, isLoading, __) => Provider<SignInBloc>(
          create: (_) => SignInBloc(auth: auth, isLoading: isLoading),
          child: Consumer<SignInBloc>(
            builder: (_, bloc, __) =>
                SignInPage(bloc: bloc, isLoading: isLoading.value),
          ),
        ),
      ),
    );
  }

  void _showSignInError(BuildContext context, PlatformException exception) {
    PlatformExceptionAlertDialog(
      title: 'Sign in failed',
      exception: exception,
    ).show(context);
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Color.fromRGBO(48, 48, 48, 1),
        brightness: Brightness.dark,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color.fromRGBO(48, 48, 48, 1)),
      child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: _buildHeader()),
            SizedBox(
              height: 30,
            ),
            SocialSignInButton(
              assetName: 'images/google-logo.png',
              text: 'Sign in with Google',
              textColor: Colors.black87,
              color: Colors.white,
              onPressed: isLoading ? null : () => _signInWithGoogle(context),
            ),
            SizedBox(height: 30.0),
            (isLoading)
                ? Center(
                    child: LinearProgressIndicator(
                      backgroundColor: Color.fromRGBO(198, 198, 198,1),
                      color: Colors.blue,
                    ),
                  )
                : Container(
                    height: 8,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Calgenda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(225, 225, 225, 1),
          ),
        ),
      ],
    );
  }
}
