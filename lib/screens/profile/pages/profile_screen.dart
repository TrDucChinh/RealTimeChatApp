import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/common/widgets/base_image.dart';
import 'package:chat_app_ttcs/models/user_model.dart';
import 'package:chat_app_ttcs/services/network_service.dart';
import 'package:chat_app_ttcs/common/helper/helper.dart';
import 'package:chat_app_ttcs/sample_token.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({
    super.key,
    required this.token,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final NetworkService _networkService;
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  final _nameController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService(baseUrl: baseUrl2, token: widget.token);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = Helper.getUserIdFromToken(widget.token);
      final response = await _networkService.get('/users/$userId');
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _user = UserModel.fromJson(userData);
          _nameController.text = _user!.username;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() => _isLoading = true);
      
      // Upload avatar first if there's a new image
      if (_selectedImage != null) {
        print('Uploading avatar file: ${_selectedImage!.path}');
        final avatarResponse = await _networkService.uploadFiles(
          '/users/avatar',
          [_selectedImage!],
          fieldName: 'avatar',
          method: 'PUT',
        );
        print('Avatar upload response: ${avatarResponse.statusCode} - ${avatarResponse.body}');
        if (avatarResponse.statusCode == 200) {
          try {
            final updatedUserData = json.decode(avatarResponse.body);
            if (updatedUserData != null && updatedUserData['avatar'] != null) {
              // Update only the avatar in the current user model
              setState(() {
                _user = UserModel(
                  id: _user!.id,
                  username: _user!.username,
                  email: _user!.email,
                  status: _user!.status,
                  lastSeen: _user!.lastSeen,
                  avatar: updatedUserData['avatar'],
                );
              });
            }
          } catch (e) {
            print('Error parsing avatar update response: $e');
          }
        } else {
          final errorData = json.decode(avatarResponse.body);
          throw Exception(errorData['message'] ?? 'Failed to update avatar: ${avatarResponse.statusCode}');
        }
      }

      // Update username
      final formData = {
        'username': _nameController.text,
      };
      final response = await _networkService.put('/users/profile', body: formData);
      if (response.statusCode == 200) {
        try {
          final userData = json.decode(response.body);
          if (userData != null) {
            setState(() {
              _user = UserModel.fromJson(userData);
            });
          }
        } catch (e) {
          print('Error parsing user data: $e');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update username: ${response.statusCode}');
      }

      setState(() {
        _isEditing = false;
        _isLoading = false;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Profile update error: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(child: Text('Failed to load profile'));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor_500,
        title: Text(
          'Profile',
          style: AppTextStyles.bold_20px.copyWith(color: AppColors.white),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.white),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save, color: AppColors.white),
              onPressed: _updateProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60.r,
                    backgroundColor: AppColors.neutral_200,
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              width: 120.r,
                              height: 120.r,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _user!.avatarUrl.isNotEmpty
                            ? ClipOval(
                                child: BaseCacheImage(
                                  url: _user!.avatarUrl,
                                  width: 120.r,
                                  height: 120.r,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 80.r,
                                color: AppColors.white,
                              ),
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor_500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: EdgeInsets.all(8.r),
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            if (_isEditing)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              )
            else
              Text(
                _user!.username,
                style: AppTextStyles.bold_20px,
              ),
            SizedBox(height: 16.h),
            Text(
              _user!.email,
              style: AppTextStyles.regular_16px.copyWith(
                color: AppColors.neutral_500,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.neutral_100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: _user!.status == 'online'
                        ? Colors.green
                        : AppColors.neutral_400,
                    size: 12.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _user!.status,
                    style: AppTextStyles.regular_14px.copyWith(
                      color: AppColors.neutral_600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
} 