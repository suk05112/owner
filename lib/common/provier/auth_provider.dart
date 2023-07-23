import 'package:flutter/foundation.dart';
import 'package:owner/common/api/API.dart';

/*
enum OAuthProviderUser { kakaoUser, googleUser }

class OAuthInfo {
  String provider;
  String providerId;
  String email;
  String idToken;
  String accessToken;

  OAuthInfo({
    required this.provider,
    required this.providerId,
    required this.email,
    required this.idToken,
    required this.accessToken,
  });

  String toString() {
    return 'provider: ${provider} \nproviderId: ${providerId} \nemail: ${email} \nidToken: ${idToken}\naccessToken: ${accessToken}';
  }
}

class AuthProvider extends ChangeNotifier {
  static final AuthProvider instance = AuthProvider._internal();

  factory AuthProvider() => instance;
  AuthProvider._internal() {
    print('auth singleton created');
  }

  // User? _user;
  // User? get user => _user;
  String? errorMessage;

  OAuthInfo? _oAuthInfo;
  OAuthInfo? get oAuthInfo => _oAuthInfo;

  setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  register(UserPost userPost) async {
    try {
      print('register start');
      PostUserResponse postUserResponse =
          await Api().setBaseClient(Api.STAGING_URL_V2).postUser(userPost);
      setUser(postUserResponse.user as User?);

      Api().setAccessToken(postUserResponse.access_token);
    
      print('register success');
    } catch (e) {
      printLog('register failed error: $e');
      rethrow;
    }
  }

  Future<User> login(OAuthInfo oAuthInfo) async {
    try {
      printLog('login start');
      AuthLoginResponse authLoginResponse =
          await Api().setBaseClient(Api.STAGING_URL_V2).postAuthLogin(
                AuthLoginPost(
                  provider: oAuthInfo.provider,
                  provider_id: oAuthInfo.providerId,
                  provider_token: oAuthInfo.provider == 'kakao'
                      ? oAuthInfo.accessToken
                      : oAuthInfo.idToken,
                ),
              );
      printLog('login end');

      setUser(authLoginResponse.user);

      Api().setAccessToken(authLoginResponse.access_token);
    
      printLog('login access token');
      log(authLoginResponse.access_token);
      printLog('auto login success');

      return authLoginResponse.user;
    } on DioError catch (e) {
      printLog('login failed $e');
      rethrow;
    } catch (e) {
      printLog(e);
      rethrow;
    }
  }

  Future<User?> autoLogin(refreshToken) async {
    try {
      printLog('auto login start');
      HttpResponse<AuthRefreshResponse> authRefreshResponse = await Api()
          .setBaseClient(Api.STAGING_URL_V2)
          .postAuthRefresh(AuthRefreshPost(refresh_token: refreshToken));

      // email이 없는 구유저일 경우 로그인 페이지로 이동 (oauth 인증 후 이메일을 받아야 되기 때문)
      if (authRefreshResponse.data.user.email == null) {
        return null;
      }

      setUser(authRefreshResponse.data.user);

      Api().setAccessToken(authRefreshResponse.data.access_token);
     
      printLog('auto login success');
      return authRefreshResponse.data.user;
    } catch (e) {
      printLog('auto login failed $e');
      rethrow;
    }
  }

  logout() async {
    try {
      printLog('logout start');
      Api().setAccessToken(null);
    
      printLog('oauth signout');
      oAuthSignOut();

      clearPreference();

      setUser(null);

      printLog('logout success');
    } catch (e) {
      printLog('logout failed $e');
    }
  }

  Future<PatchUserResponse> patchUser(UserPatch userPatch) async {
    printLog('patch user id ${user!.id}');
    PatchUserResponse patchUserResponse =
        await Api().client.patchUser(userPatch);
    setUser(patchUserResponse.user);

    printLog('user patch success');
    printLog(patchUserResponse.user.toString());
    return patchUserResponse;
  }

  void clearPreference() {
    // CheckInManager.clearCheckInPlace();
    // StepManager.clearStepTarget();

    // LoplatPreference.remove(LoplatPreference.keyLatestTimeWatchInterstitialAd);
  }
}
*/