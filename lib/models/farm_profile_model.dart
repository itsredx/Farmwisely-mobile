class FarmProfileModel {
    final int id;
   final String farmName;
   final String farmLocation;
    final String farmSize;
    final String soilType;
   final double pHValue;
   final String currentCrop;
    final String futureCrop;
    final String irrigationSystem;
  final double? latitude;
   final double? longitude;

    FarmProfileModel({
      required this.id,
       required this.farmName,
       required this.farmLocation,
       required this.farmSize,
       required this.soilType,
       required this.pHValue,
        required this.currentCrop,
       required this.futureCrop,
        required this.irrigationSystem,
       this.latitude,
       this.longitude,
     });
     factory FarmProfileModel.fromJson(Map<String, dynamic> json) {
       return FarmProfileModel(
           id: json['id'],
           farmName: json['farmName'],
          farmLocation: json['farmLocation'],
           farmSize: json['farmSize'],
            soilType: json['soilType'],
            pHValue: json['pHValue'],
            currentCrop: json['currentCrop'],
            futureCrop: json['futureCrop'],
            irrigationSystem: json['irrigationSystem'],
           latitude: json['latitude']?.toDouble(),
           longitude: json['longitude']?.toDouble(),
        );
   }
}