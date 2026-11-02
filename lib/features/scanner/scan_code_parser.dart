int? parseProductCode(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null ||
      uri.scheme.toLowerCase() != 'catalogue' ||
      uri.host.toLowerCase() != 'product' ||
      uri.pathSegments.length != 1 ||
      uri.hasQuery ||
      uri.hasFragment ||
      uri.userInfo.isNotEmpty ||
      uri.port != 0) {
    return null;
  }
  final id = int.tryParse(uri.pathSegments.single);
  return id != null && id > 0 ? id : null;
}
