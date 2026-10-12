import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}
val adProperties = Properties().apply {
    rootProject.file("ads.properties").takeIf { it.isFile }?.inputStream()?.use { load(it) }
}
fun adProperty(key: String) = adProperties.getProperty(key, "").trim()
fun quoted(value: String) = "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"") + "\""

android {
    namespace = "com.bigtimepixels.hopslide"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.bigtimepixels.hopslide"
        minSdk = 26
        targetSdk = 36
        versionCode = 2
        versionName = "1.1.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    buildFeatures { compose = true; buildConfig = true }
    buildTypes {
        debug {
            // Debug builds always use Google's test inventory, even with production properties present.
            manifestPlaceholders["admobAppId"] = "ca-app-pub-3940256099942544~3347511713"
            buildConfigField("boolean", "ADS_TEST_MODE", "true")
            buildConfigField("String", "BANNER_AD_UNIT_ID", quoted("ca-app-pub-3940256099942544/6300978111"))
            buildConfigField("String", "INTERSTITIAL_AD_UNIT_ID", quoted("ca-app-pub-3940256099942544/1033173712"))
        }
        release {
            manifestPlaceholders["admobAppId"] = adProperty("admob.appId")
            buildConfigField("boolean", "ADS_TEST_MODE", "false")
            buildConfigField("String", "BANNER_AD_UNIT_ID", quoted(adProperty("admob.bannerId")))
            buildConfigField("String", "INTERSTITIAL_AD_UNIT_ID", quoted(adProperty("admob.interstitialId")))
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    testOptions { unitTests.isReturnDefaultValues = true }
    packaging { resources.excludes += "/META-INF/{AL2.0,LGPL2.1}" }
}
kotlin { jvmToolchain(17) }
// Fail with actionable instructions rather than accidentally shipping test ads.
tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    doFirst {
        require(Regex("ca-app-pub-[0-9]{16}~[0-9]{10}").matches(adProperty("admob.appId")) &&
            listOf("admob.bannerId", "admob.interstitialId").all {
                Regex("ca-app-pub-[0-9]{16}/[0-9]{10}").matches(adProperty(it))
            } && !adProperty("admob.appId").contains("3940256099942544")) {
            "Add this Android app's production AdMob IDs to ads.properties (see ads.properties.example) before building release."
        }
    }
}
dependencies {
    implementation("com.google.android.gms:play-services-ads:25.5.0")
    implementation("com.google.android.ump:user-messaging-platform:4.0.0")
    implementation(platform("androidx.compose:compose-bom:2025.10.01"))
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.activity:activity-compose:1.11.0")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.animation:animation")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.9.4")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.9.4")
    implementation("androidx.lifecycle:lifecycle-viewmodel-savedstate:2.9.4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    testImplementation("junit:junit:4.13.2")
}
