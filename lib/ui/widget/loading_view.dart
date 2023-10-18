import 'package:flutter/material.dart';

import '../../constants.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: AppColors.inputBorder.withOpacity(0.4),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
