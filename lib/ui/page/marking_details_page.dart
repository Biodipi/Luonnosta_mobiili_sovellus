import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luonnosta_app/logic/auth_cubit.dart';
import 'package:luonnosta_app/logic/create_marking_cubit.dart';
import 'package:luonnosta_app/logic/delete_marking_cubit.dart';
import 'package:luonnosta_app/logic/update_marking_cubit.dart';
import 'package:luonnosta_app/ui/page/markings_page.dart';
import 'package:luonnosta_app/ui/widget/loading_view.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import '../../logic/list_markings_cubit.dart';
import '../../model/marking.dart';
import 'map_page.dart';

class MarkingDetailsPage extends StatefulWidget {
  const MarkingDetailsPage({Key? key}) : super(key: key);

  @override
  State<MarkingDetailsPage> createState() => _MarkingDetailsPageState();
}

class _MarkingDetailsPageState extends State<MarkingDetailsPage> {
  String? imageUrl;
  bool _editing = false;
  bool _blank = false;
  List<String> _emails = [];
  Marking? _marking;
  XFile? _pendingUploadPhoto;

  final TextEditingController _addEmailController = TextEditingController();

  TextEditingController _titleController = TextEditingController();

  TextEditingController _descController = TextEditingController();

  final String emailValidationPattern =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+";

  @override
  void dispose() {
    _addEmailController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadImage();
      setState(() {
        _titleController = TextEditingController(text: _marking!.title);
        _descController = TextEditingController(text: _marking!.description);
      });
    });
  }

  loadImage() async {
    if (_marking == null ||
        _blank ||
        _marking!.image == null ||
        _marking!.image.isEmpty) {
      setState(() {
        imageUrl = null;
      });
      return;
    }
    Reference ref =
        FirebaseStorage.instance.ref().child("images/${_marking!.image}");

    var url = await ref.getDownloadURL();

    setState(() {
      imageUrl = url;
    });
  }

  final User? _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments == null) {
      _blank = true;
      _editing = true;
      _marking = Marking.empty();
      List<String> coords = ModalRoute.of(context)!.settings.name!.split(",");
      _marking!.position = {
        "lat": double.parse(coords.first),
        "lon": double.parse(coords.last),
      };
    } else {
      _marking ??= ModalRoute.of(context)!.settings.arguments as Marking;
      _emails = _marking!.sharedWith;
    }

    return BlocConsumer<CreateMarkingCubit, CreateMarkingState>(
      listener: (context, createMarkingState) {
        if (createMarkingState is CreateMarkingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.commonError)),
          );
        }
        if (createMarkingState is CreateMarkingSuccess) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MarkingsPage()),
          );
        }
      },
      builder: (context, createMarkingState) {
        return BlocConsumer<DeleteMarkingCubit, DeleteMarkingState>(
          listener: (context, deleteMarkingState) {
            if (deleteMarkingState is DeleteMarkingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(AppLocalizations.of(context)!.commonError)),
              );
            }
            if (deleteMarkingState is DeleteMarkingSuccess) {
              Navigator.pop(context);
              context.read<ListMarkingsCubit>().listAll();
            }
          },
          builder: (context, deleteMarkingState) {
            return BlocConsumer<UpdateMarkingCubit, UpdateMarkingState>(
              listener: (context, updateMarkingState) {
                if (updateMarkingState is UpdateMarkingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.commonError)),
                  );
                }
                if (updateMarkingState is UpdateMarkingSuccess) {
                  Navigator.pop(context);
                  context.read<ListMarkingsCubit>().listAll();
                }
              },
              builder: (context, updateMarkingState) {
                return WillPopScope(
                  onWillPop: () async {
                    if (_editing) {
                      await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                content: Text(AppLocalizations.of(context)!
                                    .editQuitNoSave),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      _editing = true;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .commonExit),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _save();
                                    },
                                    child: Text(AppLocalizations.of(context)!
                                        .commonSave),
                                  ),
                                ],
                              ));
                      return false;
                    } else {
                      return true;
                    }
                  },
                  child: Stack(
                    children: [
                      Scaffold(
                          floatingActionButton: (!_blank && !_editing)
                              ? FloatingActionButton(
                                  backgroundColor: AppColors.inputBorder,
                                  onPressed: () {
                                    _exportPDF(context);
                                  },
                                  child: const Icon(Icons.picture_as_pdf),
                                )
                              : null,
                          appBar: AppBar(
                            title: _buildHeaderTitle(context),
                            centerTitle: true,
                            actions: [
                              if (_editing &&
                                  _marking != null &&
                                  _marking!.isMyOwn())
                                SizedBox(
                                  width: 100,
                                  child: IconButton(
                                    icon: Text(
                                      AppLocalizations.of(context)!.commonSave,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                      if (_isValid()) {
                                        _save();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  AppLocalizations.of(context)!
                                                      .editErrorEmptyFields)),
                                        );
                                      }
                                    },
                                  ),
                                )
                              else if (_marking!.isMyOwn())
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.white,
                                  onPressed: () {
                                    setState(() {
                                      _editing = true;
                                    });
                                  },
                                ),
                            ],
                            backgroundColor: AppColors.inputBorder,
                          ),
                          body: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 34),
                            shrinkWrap: true,
                            children: [
                              _buildImage(context),
                              const SizedBox(
                                height: 9,
                              ),
                              if (_editing)
                                _section(
                                    AppLocalizations.of(context)!.editTitle),
                              _buildTitle(context),
                              const SizedBox(
                                height: 9,
                              ),
                              _section(AppLocalizations.of(context)!.editDesc),
                              _buildDesc(context),
                              const SizedBox(
                                height: 9,
                              ),
                              _section(AppLocalizations.of(context)!.editShare),
                              _buildShare(context),
                              if (_editing && !_blank) _buildDelete(),
                              if (!_editing && !_blank) _buildShowOnMap()
                            ],
                          )),
                      if (deleteMarkingState is DeleteMarkingLoading ||
                          createMarkingState is CreateMarkingLoading ||
                          updateMarkingState is UpdateMarkingLoading)
                        const LoadingView()
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  _buildShare(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _emails.length + 1,
      itemBuilder: (context, index) {
        if (_emails.length == index) {
          if (!_editing) return const SizedBox();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      label: Text(AppLocalizations.of(context)!.editAddEmail)),
                  controller: _addEmailController,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                  onPressed: (_addEmailController.value.text.isNotEmpty)
                      ? () async {
                          if (RegExp(emailValidationPattern)
                              .hasMatch(_addEmailController.value.text)) {
                            if (await _userExists(
                                    _addEmailController.value.text) ==
                                false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .editErrorUserNotFound)),
                              );
                            } else if (_addEmailController.value.text ==
                                _user!.email) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .editErrorSelfShare)),
                              );
                            } else if (!_emails
                                .contains(_addEmailController.value.text)) {
                              _emails.add(_addEmailController.value.text);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .editErrorDuplicateShare)),
                              );
                            }
                            setState(() {
                              _addEmailController.clear();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .loginInvalidEmail)),
                            );
                          }
                        }
                      : null,
                  child: Text(AppLocalizations.of(context)!.commonOK))
            ],
          );
        }
        return ListTile(
          trailing: (!_editing)
              ? null
              : IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      _emails.remove(_emails[index]);
                    });
                  },
                ),
          title: Text(_emails[index]),
          dense: true,
        );
      },
    );
  }

  _buildDesc(BuildContext context) {
    if (_editing) {
      return TextFormField(
        controller: _descController,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12.0),
            labelStyle: const TextStyle(color: Colors.white),
            filled: true,
            errorStyle: const TextStyle(fontWeight: FontWeight.bold),
            fillColor: AppColors.greenButton,
            focusedBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            enabledBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            errorBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            border: AppBorder.textFormBorder(AppColors.inputBorder),
            focusedErrorBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            label: Center(child: Text(AppLocalizations.of(context)!.editDesc)),
            floatingLabelBehavior: FloatingLabelBehavior.never),
        minLines: 3,
        maxLines: 15,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(_marking!.description),
    );
  }

  _buildTitle(BuildContext context) {
    if (_editing) {
      return TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12.0),
            labelStyle: const TextStyle(color: Colors.white),
            filled: true,
            errorStyle: const TextStyle(fontWeight: FontWeight.bold),
            fillColor: AppColors.greenButton,
            focusedBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            enabledBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            errorBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            border: AppBorder.textFormBorder(AppColors.inputBorder),
            focusedErrorBorder: AppBorder.textFormBorder(AppColors.inputBorder),
            label: Center(child: Text(AppLocalizations.of(context)!.editTitle)),
            floatingLabelBehavior: FloatingLabelBehavior.never),
      );
    }
    return Container();
  }

  _buildImage(BuildContext context) {
    if (imageUrl == null && _pendingUploadPhoto == null && !_editing) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: (!_editing)
          ? null
          : () async {
              final ImagePicker picker = ImagePicker();
              XFile? file = await picker.pickImage(source: ImageSource.camera);
              setState(() {
                _pendingUploadPhoto = file;
              });
            },
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.grey,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_pendingUploadPhoto != null)
              Image.file(
                File(_pendingUploadPhoto!.path),
                fit: BoxFit.cover,
              ),
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
              ),
            Center(
              child: Text(
                (_editing) ? AppLocalizations.of(context)!.editChangeImage : "",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportPDF(BuildContext context) async {
    final pdf = pw.Document();
    var netImage;
    if (imageUrl != null) {
      netImage = await networkImage(imageUrl!);
    }
    final fileImage = (_pendingUploadPhoto != null)
        ? pw.MemoryImage(
            File(_pendingUploadPhoto!.path).readAsBytesSync(),
          )
        : null;
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Container(),
            pw.Text(
              _marking!.title,
              style: const pw.TextStyle(fontSize: 34),
            ),
            pw.SizedBox(height: 20),
            pw.Text(_marking!.position
                .toString()
                .replaceAll("{", "")
                .replaceAll("}", "")),
            pw.SizedBox(height: 20),
            pw.Text("Käyttäjältä ${_marking!.creator}"),
            pw.SizedBox(height: 20),
            pw.Text(_marking!.description),
            pw.SizedBox(height: 20),
            if (imageUrl != null)
              pw.Image(netImage, height: 400)
            else if (fileImage != null)
              pw.Image(fileImage, height: 400)
          ]);
        }));

    final output = await getTemporaryDirectory();
    final filePath = "${output.path}/export.pdf";
    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());
    OpenFile.open(filePath);
  }

  _buildHeaderTitle(BuildContext context) {
    if (_blank) return Text(AppLocalizations.of(context)!.landingCreate);
    if (_editing) return Text(AppLocalizations.of(context)!.landingEdit);
    return Text(_marking!.title);
  }

  void _save() {
    _marking!.description = _descController.value.text;
    _marking!.title = _titleController.value.text;
    _marking!.sharedWith = _emails;
    if (_blank) {
      context.read<CreateMarkingCubit>().create(
          _marking!,
          (_pendingUploadPhoto != null)
              ? File(_pendingUploadPhoto!.path)
              : null);
      return;
    }
    context.read<UpdateMarkingCubit>().update(_marking!,
        (_pendingUploadPhoto != null) ? File(_pendingUploadPhoto!.path) : null);
  }

  bool _isValid() {
    return _descController.value.text.isNotEmpty &&
        _titleController.value.text.isNotEmpty;
  }

  _buildDelete() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 111, 0, 22),
      child: ElevatedButton(
        onPressed: () {
          context.read<DeleteMarkingCubit>().delete(_marking!);
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(AppLocalizations.of(context)!.editDelete),
      ),
    );
  }

  _section(String s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(s),
    );
  }

  _buildShowOnMap() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 111, 0, 22),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const WMSLayerPage(),
                settings: RouteSettings(arguments: _marking)),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.greenButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(AppLocalizations.of(context)!.showOnMap),
      ),
    );
  }

  Future<bool> _userExists(String email) async {
    final response = await http.get(
      Uri.parse("${Constants.baseUrl}/user/$email"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        HttpHeaders.authorizationHeader: await AuthCubit.getAuthToken(),
      },
    );
    //200 found!!!!!!!!!
    //203 not found
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
