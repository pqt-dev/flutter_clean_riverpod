import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitWanderingCubes(
      color: Colors.orange,
    );
  }
}
