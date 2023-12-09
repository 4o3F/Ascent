import 'package:ascent/global_state.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class InfoPage extends StatelessWidget {
  InfoPage({Key? key}) : super(key: key);

  final logic = Get.put(InfoLogic());

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Image.network(
                  "https://avatars.githubusercontent.com/u/70209532",
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                "403F",
                style: TextStyle(fontSize: 30),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Source code at ",
            style: TextStyle(fontSize: 15),
          ),
          const Text(
            "https://github.com/4o3F/Ascent",
            style: TextStyle(fontSize: 15, color: Colors.indigoAccent),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Version: ${GlobalState.version}",
            style: TextStyle(fontSize: 15, color: Colors.orangeAccent),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Contact me",
            style: TextStyle(fontSize: 15),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Email: "),
              Text("4o3f@proton.me",
                  style: TextStyle(color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Discord: "),
              Text("403F", style: TextStyle(color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("QQ: "),
              Text("855857816", style: TextStyle(color: Colors.blueAccent)),
            ],
          ),
        ],
      ),
    ));
  }
}
