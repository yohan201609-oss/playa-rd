import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Optimización: Inicializar Google Maps de forma diferida después del registro de plugins
    // para reducir el impacto en el tiempo de inicio y uso de memoria
    GeneratedPluginRegistrant.register(with: self)
    
    // Inicializar Google Maps después de que los plugins estén registrados
    // Esto permite que Flutter esté listo antes de cargar el SDK pesado de Google Maps
    DispatchQueue.main.async {
      GMSServices.provideAPIKey("AIzaSyDIPQwbsomJHtz384umBS29CDd8D5nxKR0")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
