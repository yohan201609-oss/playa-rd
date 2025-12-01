import Flutter
import UIKit
import GoogleMaps

// Importar configuración local de API Key (no se sube al repositorio)
// INSTRUCCIONES:
// 1. Asegúrate de que el archivo GoogleMaps-API-Key.h esté agregado al proyecto en Xcode
// 2. Si no existe, copia GoogleMaps-API-Key.h.template a GoogleMaps-API-Key.h
// 3. Reemplaza YOUR_API_KEY_HERE con tu clave API real de Google Maps
#import "GoogleMaps-API-Key.h"

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
