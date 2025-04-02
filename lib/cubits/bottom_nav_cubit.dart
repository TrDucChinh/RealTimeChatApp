import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0); // Mặc định là tab đầu tiên (Chats)

  void updateIndex(int newIndex) => emit(newIndex);
}
