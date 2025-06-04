import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/localization/app_localizations.dart';
import '../../../config/theme/utils/app_colors.dart';
import '../../../config/theme/utils/text_styles.dart';
import '../../../models/user_model.dart';
import '../../../services/storage_service.dart';
import '../widget/member.dart';
import '../bloc/create_group_bloc.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  List<UserModel> _selectedMembers = [];
  bool _isLoading = false;

  void _onAddMembers() async {
    final token = await StorageService.getToken();
    if (token != null) {
      context.pushNamed(
        'addMembers',
        extra: {
          'token': token,
          'selectedMembers': _selectedMembers,
          'onMembersSelected': (List<UserModel> members) {
            setState(() {
              _selectedMembers = members;
            });
          },
        },
      );
    }
  }

  void _onCreateGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_enter_group_name'),
          ),
        ),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translate('please_select_members'),
          ),
        ),
      );
      return;
    }

    final token = await StorageService.getToken();
    if (token != null) {
      setState(() {
        _isLoading = true;
      });

      context.read<CreateGroupBloc>().add(
        CreateGroup(
          name: _groupNameController.text,
          members: _selectedMembers,
        ),
      );
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateGroupBloc, CreateGroupState>(
      listener: (context, state) {
        if (state is CreateGroupSuccess) {
          setState(() {
            _isLoading = false;
          });
          context.pop(); // Quay lại màn hình trước
        } else if (state is CreateGroupError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor_600,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.white.withOpacity(0),
                  AppColors.white.withOpacity(0.2),
                ],
                stops: const [0.81, 1.00],
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50.r),
              ),
            ),
          ),
          elevation: 0,
          title: Text(
            AppLocalizations.of(context).translate('create_group'),
            style: AppTextStyles.semiBold_22px.copyWith(
              color: AppColors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: AppColors.white,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('name_group'),
                style: AppTextStyles.regular_14px
                    .copyWith(color: AppColors.neutral_500),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context).translate('enter_name_group'),
                  hintStyle: AppTextStyles.regular_16px.copyWith(
                    color: AppColors.neutral_200,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.neutral_100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.neutral_100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.neutral_100),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 18.5.h,
                    horizontal: 18.5.w,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).translate('member'),
                style: AppTextStyles.regular_14px
                    .copyWith(color: AppColors.neutral_500),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _onAddMembers,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue_50,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0.r),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.blue,
                        size: 36.w,
                      ),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)
                            .translate('add_members_to_group'),
                        style: AppTextStyles.medium_18px.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedMembers.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  'Selected Members (${_selectedMembers.length})',
                  style: AppTextStyles.regular_14px
                      .copyWith(color: AppColors.neutral_500),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedMembers.length,
                    itemBuilder: (context, index) {
                      final member = _selectedMembers[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.neutral_100,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: UserTile(user: member),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedMembers.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onCreateGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue_500,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: AppColors.white)
                      : Text(
                          AppLocalizations.of(context).translate('create_group'),
                          style: AppTextStyles.bold_20px.copyWith(
                            color: AppColors.white,
                          ),
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
