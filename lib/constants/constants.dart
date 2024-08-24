class Constants {
  // static const String apiServer = 'http://192.168.1.105:8000/';
  static const String apiServer = 'http://180.128.9.83:8000/';
  // API Endpoints
  static const String ApiPodCheckin     = 'checkin'; 
  static const String ApiPodWarehouse   = 'warehouse';
  static const String ApiPodPicked      = 'picked';
  static const String ApiPodLoaded      = 'loaded';
  static const String ApiPodCfDelivery  = 'cfdelivery';
  static const String ApiPodRvDelivery  = 'rvdelivery';
  static const String ApiPodDeliveryLog = 'deliverylog'; 

  // Other constants can be added here
  static const String appName = 'TCE LIMS';
  static const int timeoutDuration = 30; // Example of a timeout duration in seconds
  static const String errorMessage = 'An error occurred. Please try again.';
}