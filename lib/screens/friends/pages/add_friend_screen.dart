import 'package:chat_app_ttcs/config/assets/app_icons.dart';
import 'package:chat_app_ttcs/config/assets/app_images.dart';
import 'package:chat_app_ttcs/config/localization/app_localizations.dart';
import 'package:chat_app_ttcs/config/theme/utils/app_colors.dart';
import 'package:chat_app_ttcs/config/theme/utils/text_styles.dart';
import 'package:chat_app_ttcs/screens/friends/bloc/add_friend_bloc.dart';
import 'package:chat_app_ttcs/screens/friends/widgets/friend_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class AddFriendScreen extends StatefulWidget {
  final String token;

  const AddFriendScreen({
    super.key,
    required this.token,
  });

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AddFriendBloc>();
    bloc.add(LoadUsers());
    bloc.add(LoadFriendRequests());
    bloc.add(LoadFriends());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AddFriendBloc>().state;
      if (state is AddFriendLoaded && !_isLoadingMore) {
        final currentPage = state.currentPage;
        final totalPages = state.totalPages;
        if (currentPage < totalPages) {
          setState(() => _isLoadingMore = true);
          context.read<AddFriendBloc>().add(LoadUsers(page: currentPage + 1));
        }
      }
    }
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
          AppLocalizations.of(context).translate('add_friend'),
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
      body: BlocListener<AddFriendBloc, AddFriendState>(
        listener: (context, state) {
          if (state is AddFriendLoaded && state.notification != null) {
            final isError = state.notification!.toLowerCase().contains('failed') || 
                          state.notification!.toLowerCase().contains('error') || state.notification!.toLowerCase().contains('exists') ;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.notification!,
                  style: AppTextStyles.regular_14px.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: isError ? AppColors.error : AppColors.success,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            );
          } else if (state is AddFriendError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: AppTextStyles.regular_14px.copyWith(
                    color: AppColors.white,
                  ),
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
              ),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context).translate('seach_friend_hint'),
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
                  isDense: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    child: SvgPicture.asset(
                      AppIcons.search,
                      height: 24.h,
                      width: 24.w,
                      color: AppColors.neutral_300,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  context
                      .read<AddFriendBloc>()
                      .add(LoadUsers(searchQuery: value));
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<AddFriendBloc, AddFriendState>(
                builder: (context, state) {
                  if (state is AddFriendLoading && state is! AddFriendLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AddFriendError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: AppTextStyles.regular_16px.copyWith(
                              color: AppColors.neutral_900,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AddFriendBloc>().add(LoadUsers());
                            },
                            child: Text(
                                AppLocalizations.of(context).translate('retry')),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AddFriendLoaded) {
                    // Keep track of previous state to maintain friends list
                    final previousState = context.read<AddFriendBloc>().state;
                    final friends = previousState is AddFriendLoaded 
                        ? previousState.friends 
                        : state.friends;

                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Friend Requests Section
                          if (state.friendRequests.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 16.h),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('friend_requests'),
                                style: AppTextStyles.semiBold_18px.copyWith(
                                  color: AppColors.neutral_900,
                                ),
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              itemCount: state.friendRequests.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                final request = state.friendRequests[index];
                                return Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neutral_200
                                            .withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24.r,
                                        backgroundImage: NetworkImage(
                                            request.sender.avatarUrl),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              request.sender.username,
                                              style: AppTextStyles.medium_16px
                                                  .copyWith(
                                                color: AppColors.neutral_900,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              request.sender.email,
                                              style: AppTextStyles.regular_14px
                                                  .copyWith(
                                                color: AppColors.neutral_500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              context.read<AddFriendBloc>().add(
                                                    RejectFriendRequest(
                                                        request.id),
                                                  );
                                            },
                                            icon: Container(
                                              padding: EdgeInsets.all(8.r),
                                              decoration: BoxDecoration(
                                                color: AppColors.error
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: AppColors.error,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          IconButton(
                                            onPressed: () {
                                              context.read<AddFriendBloc>().add(
                                                    AcceptFriendRequest(
                                                        request.id),
                                                  );
                                            },
                                            icon: Container(
                                              padding: EdgeInsets.all(8.r),
                                              decoration: BoxDecoration(
                                                color: AppColors.success
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                color: AppColors.success,
                                                size: 20.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24.h),
                          ],

                          // Friends List Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)
                                      .translate('my_friends'),
                                  style: AppTextStyles.semiBold_18px.copyWith(
                                    color: AppColors.neutral_900,
                                  ),
                                ),
                                Text(
                                  '${friends.length} ${AppLocalizations.of(context).translate('friends')}',
                                  style: AppTextStyles.regular_14px.copyWith(
                                    color: AppColors.neutral_500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state is AddFriendLoading && friends.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (friends.isEmpty)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.cardSearch,
                                    width: 200.w,
                                    height: 200.h,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('no_friends_found'),
                                    style: AppTextStyles.medium_18px.copyWith(
                                      color: AppColors.neutral_500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              itemCount: friends.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neutral_200
                                            .withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: FriendItem(
                                    userId: friends[index].id,
                                    avatarUrl: friends[index].avatarUrl,
                                    userName: friends[index].username,
                                    userEmail: friends[index].email,
                                    isFriend: true,
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: 24.h),

                          // Users List Section
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 16.h),
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('suggested_friends'),
                              style: AppTextStyles.semiBold_18px.copyWith(
                                color: AppColors.neutral_900,
                              ),
                            ),
                          ),
                          if (state.users.isEmpty)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppImages.cardSearch,
                                    width: 200.w,
                                    height: 200.h,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    AppLocalizations.of(context)
                                        .translate('no_users_found'),
                                    style: AppTextStyles.medium_18px.copyWith(
                                      color: AppColors.neutral_500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              itemCount: state.users.length +
                                  (_isLoadingMore &&
                                          state.currentPage < state.totalPages
                                      ? 1
                                      : 0),
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 16.h),
                              itemBuilder: (context, index) {
                                if (index == state.users.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                return Container(
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neutral_200
                                            .withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: FriendItem(
                                    userId: state.users[index].id,
                                    avatarUrl: state.users[index].avatarUrl,
                                    userName: state.users[index].username,
                                    userEmail: state.users[index].email,
                                    isFriend: false,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
