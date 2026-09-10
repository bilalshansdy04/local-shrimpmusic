class Playlist {
  final String id;
  final String name;
  final List<int> songIds;

  Playlist({required this.id, required this.name, List<int>? songIds}) : songIds = songIds ?? const [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
      };

  static Playlist fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        songIds: List<int>.from(json['songIds'] ?? []),
      );
}
