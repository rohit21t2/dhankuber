plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Ensure this plugin is applied
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.app.dhankuber"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.app.dhankuber"
        minSdk = 23 // Compatible with webview_flutter
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true // Added for Firebase compatibility
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.firebase:firebase-auth-ktx:23.0.0")
    implementation(platform("com.google.firebase:firebase-bom:33.2.0")) // Added Firebase BOM for consistency
    implementation("androidx.multidex:multidex:2.0.1") // Added for multiDex support
}

flutter {
    source = "../.."
}