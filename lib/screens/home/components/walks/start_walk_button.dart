import 'package:flutter/material.dart';
import '../../../../utils/helpers.dart';
import '../../../components/choose_location_dialog_func.dart';
import 'map_self_made_walk.dart';

class StartWalkingButton extends StatefulWidget {
  const StartWalkingButton({
    Key? key,
  }) : super(key: key);

  @override
  State<StartWalkingButton> createState() => _StartWalkingButtonState();
}

class _StartWalkingButtonState extends State<StartWalkingButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ElevatedButton.icon(
          onPressed: () async {
            final location = await chooseLocationDialog(context);
            if (location == null || !mounted) return;
            pushPage(
              context,
              to: SelfMadeWalkMap(
                points: location,
                mode: SelfMadeWalkMapMode.walk,
                startedAt: DateTime.now(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          label: const Text("Start Walking",style: TextStyle(
              color: Colors.white
          ),),
        ),
      ),
    );
  }
}
