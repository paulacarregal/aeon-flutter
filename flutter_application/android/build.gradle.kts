plugins {
    // Adicionamos o plugin do Kotlin com uma versÃ£o estÃ¡vel e compatÃ­vel com o NDK 28
    // Kotlin is managed by Flutter's built-in Kotlin support (android.builtInKotlin=true)
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven("https://download.flutter.io")
    }
}


subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
