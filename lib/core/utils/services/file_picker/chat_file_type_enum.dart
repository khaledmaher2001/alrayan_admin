enum ChatFileType {
  png,
  jpg,
  jpeg,
  pdf,
  docx,
  xlsx,
  mp4,
  m4a,
  mp3,
  gif,
  zip,
  rar,
  txt,
  csv,
  html,
  xml,
  json,
  svg,
  bmp,
  webp,
  pptx;

  static List<String> get types => values.map((e) => e.name).toList();
}
