class PlacePredictions {
  // ignore: non_constant_identifier_names
  late String secondary_text;
  // ignore: non_constant_identifier_names
  late String main_text;
   // ignore: non_constant_identifier_names
   late String place_id;

  // ignore: non_constant_identifier_names
  PlacePredictions({required this.secondary_text, required this.main_text, required this.place_id});
 PlacePredictions.fromJson(Map<String, dynamic> json) {
    place_id = json["place_id"] ?? "";
    secondary_text = json["structured_formatting"]["secondary_text"] ?? "";
    main_text = json["structured_formatting"]["main_text"] ?? "";
  }
}
