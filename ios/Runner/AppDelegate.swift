import Flutter
import UIKit
import GoogleMaps
import UserNotifications

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
    
    // Configurar notificaciones push
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
   
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Manejar el registro exitoso para notificaciones remotas
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Pasar el token APNS a Firebase Messaging
    // Firebase Messaging manejará esto automáticamente a través del plugin
    print("✅ Token APNS registrado correctamente")
  }
  
  // Manejar errores en el registro de notificaciones remotas
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("⚠️ Error registrando para notificaciones remotas: \(error.localizedDescription)")
  }
}
