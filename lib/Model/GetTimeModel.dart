import 'dart:convert';
/// destination_addresses : ["Subhash Marg, Imli Bazar Square, Risi Nagar, Tilak Path, Indore, Madhya Pradesh 452004, India"]
/// origin_addresses : ["39 SHUKARWARIYA HAT, Old Town, Gomti Nagar, Dewas, Madhya Pradesh 455001, India"]
/// rows : [{"elements":[{"distance":{"text":"39.9 km","value":39872},"duration":{"text":"1 hour 3 mins","value":3784},"status":"OK"}]}]
/// status : "OK"

GetTimeModel getTimeModelFromJson(String str) => GetTimeModel.fromJson(json.decode(str));
String getTimeModelToJson(GetTimeModel data) => json.encode(data.toJson());
class GetTimeModel {
  GetTimeModel({
      List<String>? destinationAddresses, 
      List<String>? originAddresses, 
      List<Rows>? rows, 
      String? status,}){
    _destinationAddresses = destinationAddresses;
    _originAddresses = originAddresses;
    _rows = rows;
    _status = status;
}

  GetTimeModel.fromJson(dynamic json) {
    _destinationAddresses = json['destination_addresses'] != null ? json['destination_addresses'].cast<String>() : [];
    _originAddresses = json['origin_addresses'] != null ? json['origin_addresses'].cast<String>() : [];
    if (json['rows'] != null) {
      _rows = [];
      json['rows'].forEach((v) {
        _rows?.add(Rows.fromJson(v));
      });
    }
    _status = json['status'];
  }
  List<String>? _destinationAddresses;
  List<String>? _originAddresses;
  List<Rows>? _rows;
  String? _status;
GetTimeModel copyWith({  List<String>? destinationAddresses,
  List<String>? originAddresses,
  List<Rows>? rows,
  String? status,
}) => GetTimeModel(  destinationAddresses: destinationAddresses ?? _destinationAddresses,
  originAddresses: originAddresses ?? _originAddresses,
  rows: rows ?? _rows,
  status: status ?? _status,
);
  List<String>? get destinationAddresses => _destinationAddresses;
  List<String>? get originAddresses => _originAddresses;
  List<Rows>? get rows => _rows;
  String? get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['destination_addresses'] = _destinationAddresses;
    map['origin_addresses'] = _originAddresses;
    if (_rows != null) {
      map['rows'] = _rows?.map((v) => v.toJson()).toList();
    }
    map['status'] = _status;
    return map;
  }

}

/// elements : [{"distance":{"text":"39.9 km","value":39872},"duration":{"text":"1 hour 3 mins","value":3784},"status":"OK"}]

Rows rowsFromJson(String str) => Rows.fromJson(json.decode(str));
String rowsToJson(Rows data) => json.encode(data.toJson());
class Rows {
  Rows({
      List<Elements>? elements,}){
    _elements = elements;
}

  Rows.fromJson(dynamic json) {
    if (json['elements'] != null) {
      _elements = [];
      json['elements'].forEach((v) {
        _elements?.add(Elements.fromJson(v));
      });
    }
  }
  List<Elements>? _elements;
Rows copyWith({  List<Elements>? elements,
}) => Rows(  elements: elements ?? _elements,
);
  List<Elements>? get elements => _elements;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_elements != null) {
      map['elements'] = _elements?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// distance : {"text":"39.9 km","value":39872}
/// duration : {"text":"1 hour 3 mins","value":3784}
/// status : "OK"

Elements elementsFromJson(String str) => Elements.fromJson(json.decode(str));
String elementsToJson(Elements data) => json.encode(data.toJson());
class Elements {
  Elements({
      Distance? distance, 
      Duration? duration, 
      String? status,}){
    _distance = distance;
    _duration = duration;
    _status = status;
}

  Elements.fromJson(dynamic json) {
    _distance = json['distance'] != null ? Distance.fromJson(json['distance']) : null;
    _duration = json['duration'] != null ? Duration.fromJson(json['duration']) : null;
    _status = json['status'];
  }
  Distance? _distance;
  Duration? _duration;
  String? _status;
Elements copyWith({  Distance? distance,
  Duration? duration,
  String? status,
}) => Elements(  distance: distance ?? _distance,
  duration: duration ?? _duration,
  status: status ?? _status,
);
  Distance? get distance => _distance;
  Duration? get duration => _duration;
  String? get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_distance != null) {
      map['distance'] = _distance?.toJson();
    }
    if (_duration != null) {
      map['duration'] = _duration?.toJson();
    }
    map['status'] = _status;
    return map;
  }

}

/// text : "1 hour 3 mins"
/// value : 3784

Duration durationFromJson(String str) => Duration.fromJson(json.decode(str));
String durationToJson(Duration data) => json.encode(data.toJson());
class Duration {
  Duration({
      String? text, 
      int? value,}){
    _text = text;
    _value = value;
}

  Duration.fromJson(dynamic json) {
    _text = json['text'];
    _value = json['value'];
  }
  String? _text;
  int? _value;
Duration copyWith({  String? text,
  int? value,
}) => Duration(  text: text ?? _text,
  value: value ?? _value,
);
  String? get text => _text;
  int? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['text'] = _text;
    map['value'] = _value;
    return map;
  }

}

/// text : "39.9 km"
/// value : 39872

Distance distanceFromJson(String str) => Distance.fromJson(json.decode(str));
String distanceToJson(Distance data) => json.encode(data.toJson());
class Distance {
  Distance({
      String? text, 
      int? value,}){
    _text = text;
    _value = value;
}

  Distance.fromJson(dynamic json) {
    _text = json['text'];
    _value = json['value'];
  }
  String? _text;
  int? _value;
Distance copyWith({  String? text,
  int? value,
}) => Distance(  text: text ?? _text,
  value: value ?? _value,
);
  String? get text => _text;
  int? get value => _value;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['text'] = _text;
    map['value'] = _value;
    return map;
  }

}