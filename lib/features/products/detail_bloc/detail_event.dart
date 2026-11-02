part of 'detail_bloc.dart';

sealed class DetailEvent {}

class DetailStarted extends DetailEvent {}

class DetailRetried extends DetailEvent {}
