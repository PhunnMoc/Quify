import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quify/core/theme/app_theme.dart';
import 'package:quify/core/utils/validators.dart';
import 'package:quify/core/values/app_strings.dart';
import 'package:quify/core/values/app_dimens.dart';
import 'package:quify/core/widgets/custom_button.dart';
import 'package:quify/core/widgets/custom_input_field.dart';
import 'package:quify/features/profile/controller/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  EditProfileView({super.key});
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
        actions: [
          Obx(
            () => controller.isEditing.value
                ? IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              controller.saveProfile();
                            }
                          },
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: controller.toggleEdit,
                  ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value && controller.userData == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.paddingXL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Avatar
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              controller.fullNameController.text.isNotEmpty
                                  ? controller.fullNameController.text[0]
                                      .toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Full Name Field
                        CustomInputField(
                          label: AppStrings.fullName,
                          controller: controller.fullNameController,
                          validator: Validators.fullName,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: const Icon(Icons.person_outlined),
                          enabled: controller.isEditing.value,
                        ),
                        const SizedBox(height: AppDimens.marginM),
                        // Username Field
                        Obx(
                          () => CustomInputField(
                            label: AppStrings.username,
                            controller: controller.usernameController,
                            validator: Validators.username,
                            keyboardType: TextInputType.text,
                            prefixIcon: const Icon(Icons.alternate_email),
                            enabled: controller.isEditing.value,
                            suffixIcon: controller.isCheckingUsername.value
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                            onChanged: controller.isEditing.value
                                ? (value) {
                                    controller.checkUsername(value);
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppDimens.marginM),
                        // Email Field (disabled)
                        CustomInputField(
                          label: AppStrings.email,
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          enabled: false,
                        ),
                        const SizedBox(height: AppDimens.marginL),
                        // Save Button (only show when editing)
                        Obx(
                          () => controller.isEditing.value
                              ? CustomButton(
                                  text: AppStrings.save,
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            controller.saveProfile();
                                          }
                                        },
                                  isLoading: controller.isLoading.value,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

