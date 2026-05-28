class PostModel {
  final String id;
  final String title;
  final String city;
  final String category;
  final String story;
  final String userEmail;

  final int usefulCount;

  final List<dynamic> usefulVotes;

  PostModel({
    required this.id,
    required this.title,
    required this.city,
    required this.category,
    required this.story,
    required this.userEmail,

    required this.usefulCount,
    required this.usefulVotes,
  });
}
