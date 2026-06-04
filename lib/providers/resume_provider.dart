import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResumeProvider extends ChangeNotifier {
	int resumeCount = 0;
	List<Map<String, dynamic>> resumes = [];

	StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

	ResumeProvider() {
		_init();
	}

	void _init() {
		FirebaseAuth.instance.authStateChanges().listen((user) {
			_sub?.cancel();
			if (user != null) {
				_startListening(user.uid);
			} else {
				resumeCount = 0;
				resumes = [];
				notifyListeners();
			}
		});
	}

	void _startListening(String uid) {
		_sub = FirebaseFirestore.instance
				.collection('users')
				.doc(uid)
				.collection('resumes')
				.orderBy('uploadedAt', descending: true)
				.snapshots()
				.listen((snapshot) {
			resumes = snapshot.docs
					.map((d) => {'id': d.id, ...d.data()})
					.toList();
			resumeCount = resumes.length;
			notifyListeners();
		}, onError: (e) {
			debugPrint('❌ ResumeProvider listen error: $e');
		});
	}

	@override
	void dispose() {
		_sub?.cancel();
		super.dispose();
	}
}
