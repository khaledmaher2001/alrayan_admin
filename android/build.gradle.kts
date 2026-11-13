// Workaround for file_picker (pub) under AGP >= 9.
//
// file_picker's own android/build.gradle skips applying the legacy
// `org.jetbrains.kotlin.android` plugin once it detects AGP 9+, assuming
// AGP's built-in Kotlin compiler will pick up its .kt sources instead. This
// project has that built-in compiler turned off project-wide
// (`android.builtInKotlin=false` in android/gradle.properties) because
// Flutter's own Gradle plugin still needs the legacy path for `:app` on
// Flutter 3.47.2. With built-in Kotlin off, nobody compiles file_picker's
// Kotlin sources, so `FilePickerPlugin` never lands in its output jar and
// `:app`'s GeneratedPluginRegistrant fails with "cannot find symbol".
//
// Force the legacy plugin onto :file_picker specifically — the same thing
// firebase_core / package_info_plus already do unconditionally, which is
// why they build fine. The applied Kotlin version comes from the
// `pluginManagement { plugins { ... } }` block in settings.gradle.kts.
// Safe to remove once file_picker checks android.builtInKotlin itself
// instead of only the AGP major version.
subprojects {
    // Force third-party Flutter plugins that still apply the Kotlin Gradle Plugin
    // (file_picker, fluttertoast, package_info_plus, shared_preferences_android, ...)
    // to compile Java and Kotlin at the same JVM target, which AGP 9 / newer KGP
    // require to be consistent. Registered before evaluationDependsOn so the
    // afterEvaluate callback is queued before those projects get evaluated.
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
            if (compileSdkVersion?.removePrefix("android-")?.toIntOrNull()?.let { it < 36 } != false) {
                compileSdkVersion(36)
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
