
import 'package:frontend_flutter/data/story.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';



Future<void> saveStory(Story story) async {
  var box = await Hive.openBox<Story>('storiesBox');
  try {
    await box.put(formatDateKey(story.creationDate), story);
  } catch(e){
    //
  }

  await box.close();
}

Future<void> removeStory(Story story) async {
  var box = await Hive.openBox<Story>('storiesBox');
  box.delete(formatDateKey(story.creationDate));
  await box.close();
}

Future<Story?> getStory(DateTime creationDate) async {
  var box = await Hive.openBox<Story>('storiesBox');
  Story? story = box.get(formatDateKey(creationDate));
  await box.close();
  return story;
}

Future<List<Story>> getAllStories() async {
  var box = await Hive.openBox<Story>('storiesBox');
  List<Story> stories = box.values.toList();

  await box.close();
  return stories.reversed.toList();
}

String formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

String formatDateKey(DateTime date) {
  return DateFormat('yyyyMMddHHmmss').format(date.toUtc());
}




