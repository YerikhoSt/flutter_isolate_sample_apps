import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:isolate_sample_apps/hive_extension.dart';

@RoutePage()
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ValueListenableBuilder<Box<dynamic>>(
          valueListenable: Hive.box('notificationV2').listenable(),
          builder: (context, box, _) {
            final values = box.values.toList().cast<dynamic>();

            if (values.isEmpty) {
              return const SizedBox();
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                    itemCount: values.length,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(values[index]['title'].toString()),
                            Text(values[index]['description'].toString()),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
