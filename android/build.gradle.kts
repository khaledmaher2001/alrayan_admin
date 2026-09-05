allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
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
