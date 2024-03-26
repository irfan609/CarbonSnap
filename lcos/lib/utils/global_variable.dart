import 'package:flutter/material.dart';
import 'package:lcos/screens/add_post_screen.dart';
import 'package:lcos/screens/feed_screen.dart';
import 'package:lcos/screens/search_screen.dart';

const webScreenSize = 600;
dynamic results;
String? nameStarted = '';

// Create a controller instance for the FeedScreen
final TextEditingController feedScreenController = TextEditingController();

List<Widget> homeScreenItems = [
  FeedScreen(searchQueryController: feedScreenController),
  const SearchScreen(),
  const AddPostScreen(),
];
