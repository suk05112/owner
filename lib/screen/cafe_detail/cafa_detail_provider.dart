import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';

// import '../../../../common/util.dart';

// /// Example reward events.
class Reward {
  String reward;
  bool missionCompleted;

  Reward(this.reward, this.missionCompleted);

  @override
  String toString() => reward;
}
/*
class HomeProvider extends ChangeNotifier {
  final rewards = <String, Reward>{};

  User? myInfo;
  bool isLoadedMyCredit = false;
  bool isLoadedMyMonthlyRewards = false;
  bool isLoadedQuestMission = false;

  bool isCheckInMissionDone = false;
  bool isStepMissionDone = false;
  bool isEnableStepMission = false;

  void fetchMonthlyCredit() async {
    final today = DateTime.now();
    final thisMonth = DateFormat('yyyy-MM')
        .format(DateTime(today.year, today.month, today.day));
    Api().client.getMonthlyCredit(thisMonth, thisMonth).then((response) => {
          response.items?.forEach((key, value) {
            rewards[key] = Reward(convertComma(value.credit), value.done);
          }),
          isLoadedMyMonthlyRewards = true,
          notifyListeners()
        });
  }

  // TODO: get My Rewards
  void fetchMyCredit() async {
    Api().client.getMe().then((response) => {
          myInfo = response,
          printLog('my credit ${response.credit}'),
          isLoadedMyCredit = true,
          notifyListeners()
        });
  }

  void addTodayCredit(DateTime today, int credit) {
    final todayKey = DateFormat('yyyy-MM-dd')
        .format(DateTime(today.year, today.month, today.day));

    if (rewards.containsKey(todayKey)) {
      String? todayReward = rewards[todayKey]?.reward;
      rewards[todayKey]?.reward =
          convertComma(int.parse(todayReward ?? '0') + credit);
    }
  }

  DailyMissionQuestResponse? quests;
  String? studyRewarded;

  void fetchQuests() async {
    Api().client.getQuests().then((response) async {
      studyRewarded = response.studies.rewarded_at?.rewarded_at;
      quests = response;

      isStepMissionDone = response.steps != null;
      if (!isStepMissionDone) {
        int lastStepCount = await StepManager.getLastStepCount();
        isEnableStepMission = lastStepCount >= StepManager.targets.last;
      } else {
        isEnableStepMission = true;
      }

      isCheckInMissionDone = response.checkins.rewarded_at != null;
      for (var it in response.checkins.checkins) {
        if (it.store != null) {
          String branch =
              (it.store!.branch_name == null) ? '' : it.store!.branch_name!;
          Map<String, dynamic> jsonData = jsonDecode('{"place":{}}');
          jsonData['placeEvent'] = 1;
          jsonData['place']['loplat_id'] = it.pid;
          jsonData['place']['name'] = '${it.store!.name}$branch';
          jsonData['place']['category_code'] = it.store!.category_code;
          jsonData['createdAt'] = it.request_id_ts.millisecondsSinceEpoch;

          await CheckInManager.putCheckInPlace(jsonEncode(jsonData), true);
        }
      }

      isLoadedQuestMission = true;
      notifyListeners();
    });
  }

  void postCreditRewardAt(int kind, Function? onComplete) {
    Api().client.postCredit(CreditPost(kind: kind)).then((response) {
      AuthProvider().addCredit(response.credit);
      printLog(
          "HomeProvider postCredit response [${response.rewarded_at}], [${response.credit}], [${response.kind}], [${response.title}], [${response.message}]");
      if (onComplete != null) onComplete();

      switch (kind) {
        case CreditKind.checkInDailyMission:
          isCheckInMissionDone = true;
          break;
        case CreditKind.stepDailyMission:
          isStepMissionDone = true;
          break;
      }

      notifyListeners();
    }).onError((error, stackTrace) {
      DioError dioError = error as DioError;
      printLog("HomeProvider postCreditRewardAt Error [${dioError.response}]");
      if (dioError.response?.statusCode == 400) {
        notifyListeners();
      }
    });
  }
}
*/
