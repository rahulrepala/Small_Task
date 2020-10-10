class Rate {
  String _name;
  double _rate;
  int _id;

  Rate(
    this._name,
    this._rate,
  );

  Rate.map(dynamic obj) {
    this._name = obj['name'];
    this._rate = obj['rate'];
    this._id = obj['id'];
  }

  String get name => _name;
  double get rate => _rate;
  int get id => _id;
  
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map["name"] = _name;
    map["rate"] = _rate;
    if (id != null) {
      map["id"] = _id;
    }
    return map;
  }

  Rate.fromMap(Map<String, dynamic> map) {
    this._name = map['name'];
    this._rate = map['rate'];
    this._id = map["id"];
  }
}
