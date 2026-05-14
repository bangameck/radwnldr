plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // UBAH PACKAGE NAME DI SINI
    namespace = "com.radevanka.radwnldr"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = false
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // Pastikan Application ID sudah benar sesuai permintaanmu
        applicationId = "com.radevanka.radwnldr"
        
        // Gunakan variabel ini agar dia mengambil nilai dari local.properties
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            
            // ========================================================
            // OBAT JNI CRASH: MATIKAN MESIN PENGACAK R8/PROGUARD
            // ========================================================
            isMinifyEnabled = false
            isShrinkResources = false
            // ========================================================
        }
    }
}

flutter {
    source = "../.."
}