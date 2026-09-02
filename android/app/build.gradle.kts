plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.doanhdd.vimes_inventory"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.doanhdd.vimes_inventory"
        // cloud_firestore / firebase_auth require API 23+.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Native product flavors are intentionally NOT defined here: the base uses
    // Dart-level flavors (lib/core/flavors + main_<flavor>.dart entry points) so
    // `flutter run` works with no native config on either platform. Add Android
    // `productFlavors` (and matching iOS schemes) only when you need distinct
    // applicationIds / Firebase projects per environment — see README.
}

flutter {
    source = "../.."
}
