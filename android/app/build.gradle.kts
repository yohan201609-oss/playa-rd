import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin for Firebase
    id("com.google.gms.google-services")
}

// Cargar propiedades del keystore si existe
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("⚠️ key.properties no encontrado. Usando configuración de debug para release.")
    println("⚠️ Para producción, crea android/key.properties con las credenciales del keystore.")
}

android {
    namespace = "com.playasrd.playasrd"
    // SDK 36 requerido por los plugins actuales
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Habilitar desugaring para flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
        freeCompilerArgs += listOf(
            "-Xjvm-default=all",
            "-Xopt-in=kotlin.RequiresOptIn"
        )
    }

    defaultConfig {
        // Playas RD - Descubre las mejores playas de República Dominicana
        applicationId = "com.playasrd.playasrd"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        // SDK 36 requerido por los plugins actuales
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                println("✅ Configuración de signing de release cargada desde key.properties")
            } else {
                println("⚠️ key.properties no encontrado. Usando debug signing para release.")
            }
        }
    }

    buildTypes {
        release {
            // Usar signing config de release si está disponible, sino usar debug
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            
            // Habilitar minificación y ofuscación para producción
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Workaround para rutas con espacios en Android SDK
            // El stripping de símbolos falla con rutas que contienen espacios
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring para flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
