import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:certain/blocs/authentication/authentication_bloc.dart';
import 'package:certain/blocs/authentication/authentication_event.dart';
import 'package:certain/blocs/profile/bloc.dart';

import 'package:certain/helpers/constants.dart';
import 'package:certain/views/widgets/gender_widget.dart';

class ProfileForm extends StatefulWidget {
  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();

  String gender, interestedIn;
  DateTime birthdate;
  File photo;
  GeoPoint location;
  ProfileBloc _profileBloc;

  bool get isFilled =>
      _nameController.text.isNotEmpty &&
      gender != null &&
      interestedIn != null &&
      photo != null &&
      birthdate != null;

  bool isButtonEnabled(ProfileState state) {
    return isFilled && !state.isSubmitting;
  }

  _getLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    location = GeoPoint(position.latitude, position.longitude);
  }

  _onSubmitted() async {
    await _getLocation();
    _profileBloc.add(
      Submitted(
          name: _nameController.text,
          birthdate: birthdate,
          location: location,
          gender: gender,
          interestedIn: interestedIn,
          photo: photo),
    );
  }

  @override
  void initState() {
    _getLocation();
    _profileBloc = BlocProvider.of<ProfileBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<ProfileBloc, ProfileState>(
      //cubit: _profileBloc,
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Création du profil échoué'),
                    Icon(Icons.error)
                  ],
                ),
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Création...'),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: backgroundColor,
              width: size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: size.width,
                    child: CircleAvatar(
                        radius: size.width * 0.3,
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                            onTap: () async {
                              FilePickerResult result = await FilePicker
                                  .platform
                                  .pickFiles(type: FileType.image);
                              if (result != null) {
                                File getPic = File(result.files.single.path);
                                setState(() {
                                  photo = getPic;
                                });
                              }
                            },
                            child: photo == null
                                ? Image.asset('assets/profilephoto.png')
                                : CircleAvatar(
                                    radius: size.width * 0.3,
                                    backgroundImage: FileImage(photo),
                                  ))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.height * 0.02),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Nom",
                        labelStyle: TextStyle(
                            color: Colors.white, fontSize: size.height * 0.03),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        showTitleActions: true,
                        minTime: DateTime(1900, 1, 1),
                        maxTime: DateTime(DateTime.now().year - 19, 1, 1),
                        onConfirm: (date) {
                          setState(() {
                            birthdate = date;
                          });
                        },
                      );
                    },
                    child: Text(
                      "Date d'anniversaire",
                      style: TextStyle(
                          color: Colors.white, fontSize: size.width * 0.09),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.height * 0.02),
                        child: Text(
                          "Tu es:",
                          style: TextStyle(
                              color: Colors.white, fontSize: size.width * 0.09),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          genderWidget(FontAwesomeIcons.venus, "Female", size,
                              gender == "Female", () {
                            setState(() {
                              gender = "Female";
                            });
                          }),
                          genderWidget(FontAwesomeIcons.mars, "Male", size,
                              gender == "Male", () {
                            setState(() {
                              gender = "Male";
                            });
                          }),
                          genderWidget(
                            FontAwesomeIcons.transgender,
                            "Transgender",
                            size,
                            gender == "Transgender",
                            () {
                              setState(
                                () {
                                  gender = "Transgender";
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.height * 0.02),
                        child: Text(
                          "Tu cherche:",
                          style: TextStyle(
                              color: Colors.white, fontSize: size.width * 0.09),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          genderWidget(FontAwesomeIcons.venus, "Female", size,
                              interestedIn == "Female", () {
                            setState(() {
                              interestedIn = "Female";
                            });
                          }),
                          genderWidget(FontAwesomeIcons.mars, "Male", size,
                              interestedIn == "Male", () {
                            setState(() {
                              interestedIn = "Male";
                            });
                          }),
                          genderWidget(
                            FontAwesomeIcons.transgender,
                            "Transgender",
                            size,
                            interestedIn == "Transgender",
                            () {
                              setState(
                                () {
                                  interestedIn = "Transgender";
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    child: GestureDetector(
                      onTap: () {
                        if (isButtonEnabled(state)) {
                          _onSubmitted();
                        } else {}
                      },
                      child: Container(
                        width: size.width * 0.8,
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                          color: isButtonEnabled(state)
                              ? Colors.white
                              : Colors.grey,
                          borderRadius:
                              BorderRadius.circular(size.height * 0.05),
                        ),
                        child: Center(
                            child: Text(
                          "Enregistrer",
                          style: TextStyle(
                              fontSize: size.height * 0.025,
                              color: Colors.blue),
                        )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
