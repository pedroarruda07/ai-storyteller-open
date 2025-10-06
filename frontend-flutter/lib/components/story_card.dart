import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../utils/db_utils.dart';
import '../data/story.dart';
import '../pages/story_page.dart';

class StoryCard extends StatelessWidget {
  final Story story;

  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShowCaseWidget(
                  builder : (context) => StoryPage(
                  story: story,
                  isSaved: true,
                ),)
              ),
            ),
        child: Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              // Placeholder color if there's no image
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: story.photo == null
                                ? const Icon(Icons.image)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.memory(story
                                        .photo!)
                                    ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(formatDate(story.creationDate),
                              style: const TextStyle(color: Color(0xffbaa4f5)))
                        ]),
                        const SizedBox(width: 10),
                        // Title and Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                story.text,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
  }
}
