import Flutter
import UIKit
import GoogleMaps

// La API Key se importa a través del Bridging Header (Runner-Bridging-Header.h)
// El archivo GoogleMaps-API-Key.h debe estar agregado al proyecto en Xcode

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
      GMSServices.provideAPIKey(GOOGLE_MAPS_API_KEY)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
