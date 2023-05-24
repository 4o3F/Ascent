import 'package:ascent/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

import '../generated/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        height: MediaQuery.of(context).size.height * 0.08,
        child: IconButton(
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.send),
          onPressed: () {
            if (AscentGlobalState.INSTANCE.getPairingStatus() ==
                PairingStatus.REQUIRED) {
              AscentGlobalState.INSTANCE.ascentStage.value = AscentStage.PAIR;
              Get.toNamed("/pair");
            } else {
              Get.toNamed("/connecting");
            }
          },
        ),
      ),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  S.current.stages,
                  style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: TextDecoration.none),
                ),
              ],
            )),
        Expanded(
          child: Timeline(
            children: [
              TimelineModel(
                  SizedBox(
                      width: double.infinity,
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                      text: "${S.current.stage_pairing}",
                                      style: const TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])),
                                  Text(S.current.stage_pairing_description),
                                ],
                              )))),
                  position: TimelineItemPosition.right,
                  iconBackground: Colors.blueAccent,
                  icon: const Icon(Icons.wifi_tethering, color: Colors.white)),
              TimelineModel(
                  SizedBox(
                      width: double.infinity,
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.current.stage_connecting,
                                    style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(S.current.stage_connecting_description),
                                ],
                              )))),
                  position: TimelineItemPosition.right,
                  iconBackground: Colors.orangeAccent,
                  icon: const Icon(Icons.network_ping, color: Colors.white)),
              TimelineModel(
                  SizedBox(
                      width: double.infinity,
                      child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.current.stage_watching,
                                    style: const TextStyle(
                                        color: Colors.deepPurpleAccent,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(S.current.stage_watching_description),
                                ],
                              )))),
                  position: TimelineItemPosition.right,
                  iconBackground: Colors.deepPurpleAccent,
                  icon: const Icon(Icons.visibility, color: Colors.white)),
            ],
            position: TimelinePosition.Left,
          ),
        )
      ]),
    );
  }
}
