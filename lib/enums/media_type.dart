enum MediaType {
  none,
  video,
  document;

  bool get isNone => this == MediaType.none;
  bool get isVideo => this == MediaType.video;
  bool get isDocument => this == MediaType.document;
}
