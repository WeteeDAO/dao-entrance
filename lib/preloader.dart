import 'dart:async';
import 'dart:convert' as convert;
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:asyou_app/native_wraper.dart';
import 'package:asyou_app/router.dart';
import 'package:asyou_app/utils/platform_infos.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'components/components.dart';
import 'store/theme.dart';
import 'utils/screen/screen.dart';
import 'package:lottie/lottie.dart';

import 'package:window_manager/window_manager.dart';

import 'apis/account_api.dart';
import 'apis/apis.dart';
import 'models/account.dart';
import 'store/im.dart';

@RoutePage(name: "preloader")
class PreloaderPage extends StatefulWidget {
  const PreloaderPage({Key? key}) : super(key: key);

  @override
  State<PreloaderPage> createState() => _PreloaderPageState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _PreloaderPageState extends State<PreloaderPage> with WindowListener {
  bool _loading = true;
  List<Account> accounts = [];
  late AppCubit im;
  late AccountApi accountStore;

  @override
  void initState() {
    super.initState();

    im = context.read();
    getList(() {
      if (accounts.isNotEmpty && !runInTest) {
        autoLogin();
      }
      if (im.connections.keys.isEmpty) {
        Timer(const Duration(milliseconds: 2000), () {
          if (!mounted) return;
          setState(() => _loading = false);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  autoLogin() async {
    const storage = FlutterSecureStorage();
    storage.read(key: "login_state").then((value) async {
      if (value != null) {
        final account = accounts.firstWhereOrNull((a) => a.address == value);
        if (account != null) {
          await waitFutureLoading(
            context: globalCtx(),
            future: () async {
              await im.loginWithCache(account);
              // ignore: use_build_context_synchronously
              Timer(const Duration(milliseconds: 1000), () {
                if (!mounted) return;
                globalCtx().router.pushNamed("/select_org?auto=t");
              });
            },
          );
        }
      }
    });
  }

  getList(Function? callback) async {
    accountStore = await AccountApi.create();
    var as = await accountStore.getUsers();
    setState(() {
      accounts = as;
    });
    callback?.call();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  selectAccountType() {
    final constTheme = Theme.of(context).extension<ExtColors>()!;
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxWidth: 100.sw, minWidth: 100.sw),
      backgroundColor: constTheme.centerChannelBg,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 25.w,
            ),
            InkWell(
              key: const Key("sr25519key"),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: constTheme.centerChannelColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      L10n.of(context)!.signUp,
                      style: TextStyle(
                        color: constTheme.centerChannelBg,
                        fontWeight: FontWeight.bold,
                        fontSize: 19.w,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () async {
                context.router.pop();
                if (accounts.length >= 3) {
                  BotToast.showText(
                    text: L10n.of(context)!.tooManyUsers,
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                await context.router.pushNamed("/sr25519key");
                getList(null);
              },
            ),
            SizedBox(
              height: 25.w,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final constTheme = Theme.of(context).extension<ExtColors>()!;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: constTheme.centerChannelBg,
      body: Center(
        child: _loading
            ? moveWindow(Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Lottie.asset(
                        'assets/infinite-loader.json',
                        repeat: true,
                        fit: BoxFit.cover,
                        width: 150.w,
                      ),
                    ),
                  ),
                  Text(
                    "DTIM",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.w, color: constTheme.centerChannelColor.withOpacity(0.2)),
                  ),
                  SizedBox(height: 20.w),
                ],
              ))
            : Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        moveWindow(SizedBox(
                          height: 70.w,
                          width: MediaQuery.of(context).size.width * 0.4,
                        )),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  L10n.of(context)!.generate,
                                  style: TextStyle(
                                    fontSize: 32.w,
                                    color: constTheme.centerChannelColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  L10n.of(context)!.welcome,
                                  style: TextStyle(
                                    fontSize: 14.w,
                                    color: constTheme.centerChannelColor.withOpacity(0.7),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(
                                  height: 40.w,
                                ),
                                Expanded(
                                  child: accounts.isNotEmpty
                                      ? ListView.builder(
                                          itemCount: accounts.length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (context, i) {
                                            return Container(
                                              margin: EdgeInsets.only(bottom: 10.w),
                                              decoration: BoxDecoration(
                                                color: constTheme.centerChannelColor.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(5.w),
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 10.w),
                                                  Avatar(
                                                    key: Key(accounts[i].address),
                                                    id: accounts[i].address,
                                                    name: accounts[i].address,
                                                    size: 50.w,
                                                    fontSize: 36,
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          accounts[i].name ?? "-",
                                                          style: TextStyle(
                                                            color: constTheme.centerChannelColor,
                                                            fontSize: 16.w,
                                                          ),
                                                        ),
                                                        Text(
                                                          accounts[i].address,
                                                          style: TextStyle(
                                                            color: constTheme.centerChannelColor,
                                                            fontSize: 12.w,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 15.w, height: 70.w),
                                                  IconButton(
                                                    key: Key("${accounts[i].name ?? "acount_$i"}_del"),
                                                    onPressed: () async {
                                                      if (OkCancelResult.ok ==
                                                          await showOkCancelAlertDialog(
                                                            useRootNavigator: false,
                                                            title: "提示",
                                                            message: "确认删除用户，用户为本地账户，删除后无法恢复",
                                                            context: globalCtx(),
                                                            okLabel: L10n.of(globalCtx())!.next,
                                                            cancelLabel: L10n.of(globalCtx())!.cancel,
                                                          )) {
                                                        await accountStore.remove(accounts[i].address);
                                                        BotToast.showText(
                                                          text: '用户删除成功',
                                                          duration: const Duration(seconds: 2),
                                                        );
                                                        getList(null);
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_outline_rounded,
                                                      color: constTheme.centerChannelColor.withOpacity(0.3),
                                                      size: 25.w,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  Container(
                                                    height: 70.w,
                                                    decoration: BoxDecoration(
                                                      color: constTheme.linkColor.withOpacity(0.3),
                                                      borderRadius: BorderRadius.horizontal(
                                                        right: Radius.circular(5.w),
                                                      ),
                                                    ),
                                                    child: InkWell(
                                                      key: Key(accounts[i].name ?? "acount_$i"),
                                                      onTap: () async {
                                                        final islogin = await im.login(accounts[i]);
                                                        if (islogin) {
                                                          globalCtx().router.pushNamed("/select_org?auto=t");
                                                        }
                                                      },
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          SizedBox(width: 25.w),
                                                          Text(
                                                            "Login",
                                                            style: TextStyle(
                                                              color: constTheme.centerChannelColor,
                                                              fontSize: 16.w,
                                                            ),
                                                          ),
                                                          SizedBox(width: 25.w),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        )
                                      : Padding(
                                          padding: EdgeInsets.symmetric(vertical: 10.w),
                                          child: Text(
                                            L10n.of(context)!.noAccount,
                                            style: TextStyle(
                                              color: constTheme.centerChannelColor.withOpacity(0.3),
                                              fontSize: 20.w,
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(
                                  height: 10.w,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!PlatformInfos.isWeb)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            margin: EdgeInsets.only(bottom: 5.w),
                            child: InkWell(
                              key: const Key("selectAccountType"),
                              onTap: () => selectAccountType(),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
                                width: double.maxFinite,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: constTheme.centerChannelColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  L10n.of(context)!.generate,
                                  style: TextStyle(
                                    color: constTheme.centerChannelBg,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!PlatformInfos.isWeb)
                          InkWell(
                            onTap: () async {
                              if (accounts.length >= 3) {
                                BotToast.showText(
                                  text: L10n.of(context)!.tooManyUsers,
                                  duration: const Duration(seconds: 2),
                                );
                                return;
                              }
                              await context.router.pushNamed("/importSr25519key");
                              getList(null);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
                              width: MediaQuery.of(context).size.width * 0.4,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                L10n.of(context)!.importAccount,
                                style: TextStyle(
                                  color: constTheme.centerChannelColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.w,
                                ),
                              ),
                            ),
                          ),
                        if (PlatformInfos.isWeb)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            margin: EdgeInsets.only(bottom: 5.w),
                            child: InkWell(
                              key: const Key("connectWallet"),
                              onTap: () async {
                                var acount = await rustApi.connectWallet();
                                List<dynamic> accountJ = convert.jsonDecode(acount);
                                List<Account> accounts = [];
                                for (var i = 0; i < accountJ.length; i++) {
                                  final chainData = accountJ[i] as Map<String, dynamic>;
                                  final chainStr = convert.jsonEncode(accountJ[i]);
                                  final initUser = Account(
                                    address: chainData["address"] as String,
                                    chainData: chainStr,
                                    orgs: [],
                                  );
                                  initUser.domain = "";
                                  initUser.chainData = chainStr;
                                  initUser.name = (chainData["meta"] as Map<String, dynamic>)["name"] as String;

                                  accounts.add(initUser);
                                }
                                await accountStore.syncUsers(accounts);
                                BotToast.showText(
                                  text: '账户创建成功，稍后您需要选择您的组织连接web3网络',
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
                                width: double.maxFinite,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: constTheme.centerChannelColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Connect wallet",
                                  style: TextStyle(
                                    color: constTheme.centerChannelBg,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 0.02.sh,
                        ),
                      ],
                    ),
                  ),
                  if (width > 800.w)
                    Expanded(
                      child: moveWindow(Container(
                        color: constTheme.sidebarBg,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (PlatformInfos.isLinux || PlatformInfos.isWindows)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () => pop(),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.w),
                                      child: Icon(
                                        Icons.close,
                                        size: 25.w,
                                        color: constTheme.sidebarText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Expanded(
                              child: Opacity(
                                opacity: 0.3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/banner.png',
                                      width: 350.w,
                                      filterQuality: FilterQuality.medium,
                                    ),
                                    SizedBox(height: 20.w),
                                    Text(
                                      "100% open source",
                                      style: TextStyle(
                                        fontSize: 30.w,
                                        color: constTheme.centerChannelColor,
                                      ),
                                    ),
                                    Text(
                                      "decentralized office tools",
                                      style: TextStyle(
                                        fontSize: 30.w,
                                        color: constTheme.centerChannelColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 65.w)
                          ],
                        ),
                      )),
                    ),
                ],
              ),
      ),
    );
  }
}
