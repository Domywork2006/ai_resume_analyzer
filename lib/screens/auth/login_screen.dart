import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(

        child: Container(

          width: 350,

          margin: const EdgeInsets.all(20),

          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(

            color: AppColors.card,

            borderRadius:
                BorderRadius.circular(20),

            boxShadow: const [

              BoxShadow(

                color:
                    Color.fromARGB(
                        30, 0, 0, 0),

                blurRadius: 15,

                offset:
                    Offset(0, 5),
              ),
            ],
          ),

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              Icon(
                Icons.description,
                size: 80,
                color:
                    AppColors.primary,
              ),

              const SizedBox(
                height: 20,
              ),

              Text(

                'AI Resume Analyzer',

                style: TextStyle(

                  color:
                      AppColors
                          .textPrimary,

                  fontSize: 28,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(

                'Analyze resumes and improve ATS scores using AI',

                textAlign:
                    TextAlign.center,

                style: TextStyle(

                  color:
                      AppColors
                          .textSecondary,

                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(

                width:
                    double.infinity,

                height: 55,

                child: ElevatedButton(

                  onPressed: () {},

                  style:
                      ElevatedButton
                          .styleFrom(

                    backgroundColor:
                        AppColors
                            .secondary,

                    foregroundColor:
                        Colors.white,
                  ),

                  child: const Text(

                    'Continue with Google',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
