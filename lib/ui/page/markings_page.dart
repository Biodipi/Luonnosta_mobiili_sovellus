import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:luonnosta_app/logic/list_markings_cubit.dart';
import 'package:luonnosta_app/model/marking.dart';
import 'package:luonnosta_app/ui/page/marking_details_page.dart';
import 'package:luonnosta_app/ui/widget/loading_view.dart';
import '../../constants.dart';

class MarkingsPage extends StatefulWidget {
  const MarkingsPage({Key? key}) : super(key: key);

  @override
  State<MarkingsPage> createState() => _MarkingsPageState();
}

class _MarkingsPageState extends State<MarkingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ListMarkingsCubit>().listAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ListMarkingsCubit, ListMarkingsState>(
      listener: (context, state) {
        if (state is ListMarkingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        List<Marking> markings = [];
        if (state is ListMarkingsLoading) return const LoadingView();
        if (state is! ListMarkingsLoading && state is! ListMarkingsError) {
          markings = (state as ListMarkingsSuccess).response;
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.landingLog),
              centerTitle: true,
              backgroundColor: AppColors.inputBorder,
            ),
            body: (markings.isEmpty)
                ? const Material(child: Center(child: Text("Ei merkintöjä")))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: markings.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 6, left: 20, right: 20),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          tileColor: markings[index].getColor(),
                          textColor: Colors.white,
                          iconColor: Colors.white,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings:
                                      RouteSettings(arguments: markings[index]),
                                  builder: (context) =>
                                      const MarkingDetailsPage()),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 26, vertical: 1),
                          title: Text(markings[index].title),
                          trailing: const Icon(Icons.arrow_right),
                          subtitle: Text(markings[index].getShareStatus()),
                        ),
                      );
                    },
                  ));
      },
    );
  }
}
