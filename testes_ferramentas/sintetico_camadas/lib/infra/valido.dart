import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../data/modelo.dart';
import '../domain/entidade.dart';
import 'servico.dart';

const importTexto = '''
import 'package:http/http.dart';
''';
