import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_app_ttcs/screens/create_group/bloc/create_group_bloc.dart';
import '../../../config/localization/app_localizations.dart';
import '../../../config/theme/utils/app_colors.dart';
import '../../../config/theme/utils/text_styles.dart';
import '../../../models/user_model.dart';
import '../widget/member.dart';

class AddMembersScreen extends StatefulWidget {
  final List<UserModel> selectedMembers;
  final ValueChanged<List<UserModel>> onMembersSelected;

  const AddMembersScreen({
    super.key,
    required this.selectedMembers,
    required this.onMembersSelected,
  });

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  late List<UserModel> selected;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedMembers);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CreateGroupBloc>().add(LoadUsers());
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<CreateGroupBloc>().state;
      if (state is CreateGroupLoaded && !_isLoadingMore && _hasMorePages) {
        if (state.currentPage < state.totalPages) {
          _isLoadingMore = true;
          _hasMorePages = state.currentPage < state.totalPages;
          context.read<CreateGroupBloc>().add(LoadUsers(
            page: state.currentPage + 1,
            searchQuery: _searchController.text,
          ),);
        } else {
          _hasMorePages = false;
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          AppLocalizations.of(context).translate('add_members_to_group'),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).translate('search'),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  _hasMorePages = true;
                  _isLoadingMore = false;
                  context.read<CreateGroupBloc>().add(LoadUsers(searchQuery: value));
                },
              ),
            ),
            Expanded(
              child: BlocConsumer<CreateGroupBloc, CreateGroupState>(
                listener: (context, state) {
                  if (state is CreateGroupLoaded) {
                    _isLoadingMore = false;
                    _hasMorePages = state.currentPage < state.totalPages;
                  }
                },
                builder: (context, state) {
                  if (state is CreateGroupLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is CreateGroupLoaded) {
                    if (state.users.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context).translate('no_users_found'),
                          style: AppTextStyles.regular_16px.copyWith(
                            color: AppColors.neutral_500,
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          itemCount: state.users.length + (_hasMorePages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.users.length) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final user = state.users[index];
                            final isChecked = selected.any((selectedUser) => selectedUser.id == user.id);
                            return CheckboxListTile(
                              value: isChecked,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selected.add(user);
                                  } else {
                                    selected.removeWhere((selectedUser) => selectedUser.id == user.id);
                                  }
                                });
                              },
                              title: UserTile(user: user),
                              controlAffinity: ListTileControlAffinity.trailing,
                            );
                          },
                        ),
                      ],
                    );
                  } else if (state is CreateGroupError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.regular_16px.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Text(
                      AppLocalizations.of(context).translate('loading'),
                      style: AppTextStyles.regular_16px.copyWith(
                        color: AppColors.neutral_500,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue_100,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).translate('cancel'),
                          style: AppTextStyles.medium_16px.copyWith(
                            color: AppColors.primaryColor_300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        widget.onMembersSelected(selected);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue_500,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).translate('add'),
                          style: AppTextStyles.medium_16px.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
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
}
