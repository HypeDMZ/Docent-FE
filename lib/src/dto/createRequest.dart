class Create {
  final String dreamName;
  final String dream;
  final String imageUrl;
  final String resolution;
  final String checklist;
  final bool isPublic;

  Create({
    required this.dreamName,
    required this.dream,
    required this.imageUrl,
    required this.resolution,
    required this.checklist,
    required this.isPublic,
  });

  Map<String, dynamic> toJson() => {
    'dream_name': dreamName,
    'dream': dream,
    'image_url': imageUrl,
    'resolution': resolution,
    'checklist': checklist,
    'is_public': isPublic,
  };
}