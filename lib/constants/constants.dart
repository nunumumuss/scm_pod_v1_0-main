class Constants {
  // static const String apiServer = 'http://192.168.1.105:8000/';
  static const String apiServer = 'http://180.128.9.83:8000/';
  // API Endpoints
  static const String ApiPodCheckin     = 'pod_checkin'; 
  static const String ApiPodWarehouse   = 'pod_warehouse';
  static const String ApiPodPicked      = 'pod_picked';
  static const String ApiPodLoaded      = 'pod_loaded';
  static const String ApiPodCfDelivery  = 'pod_cfdelivery';
  static const String ApiPodRvDelivery  = 'pod_rvdelivery';
  static const String ApiPodDeliveryLog = 'pod_deliverylog'; 

  // Other constants can be added here
  static const String appName = 'TCE LIMS';
  static const int timeoutDuration = 30; // Example of a timeout duration in seconds
  static const String errorMessage = 'An error occurred. Please try again.';
}