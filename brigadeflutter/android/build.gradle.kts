// Root-level build.gradle.kts for Flutter + Firebase

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // google services plugin for Firebase
        classpath("com.google.gms:google-services:4.4.2")
        classpath ("com.android.tools.build:gradle:8.5.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// only declare android + kotlin plugins (no versions)
plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
}

// standard clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// optional: keep Flutter’s relocated build directories
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
