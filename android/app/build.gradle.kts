import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.psyche.kelivo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.psyche.kelivo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    fun nonBlankEnv(name: String): String? = System.getenv(name)?.takeIf { it.isNotBlank() }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(keystorePropertiesFile.inputStream())
    }

    fun nonBlankProperty(name: String): String? =
        (keystoreProperties[name] as String?)?.takeIf { it.isNotBlank() }

    val envStoreFile = nonBlankEnv("STORE_FILE")
    val envStorePassword = nonBlankEnv("STORE_PASSWORD")
    val envKeyAlias = nonBlankEnv("ALIAS")
    val envKeyPassword = nonBlankEnv("KEY_PASSWORD")
    val hasEnvSigning = envStoreFile != null &&
        envStorePassword != null &&
        envKeyAlias != null &&
        envKeyPassword != null

    val propertyStoreFile = nonBlankProperty("storeFile")
    val propertyStorePassword = nonBlankProperty("storePassword")
    val propertyKeyAlias = nonBlankProperty("keyAlias")
    val propertyKeyPassword = nonBlankProperty("keyPassword")
    val hasPropertySigning = propertyStoreFile != null &&
        propertyStorePassword != null &&
        propertyKeyAlias != null &&
        propertyKeyPassword != null

    signingConfigs {
        create("release") {
            when {
                hasEnvSigning -> {
                    storeFile = file(envStoreFile!!)
                    storePassword = envStorePassword!!
                    keyAlias = envKeyAlias!!
                    keyPassword = envKeyPassword!!
                }
                hasPropertySigning -> {
                    storeFile = file(propertyStoreFile!!)
                    storePassword = propertyStorePassword!!
                    keyAlias = propertyKeyAlias!!
                    keyPassword = propertyKeyPassword!!
                }
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (hasEnvSigning || hasPropertySigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for core library desugaring (used by flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
