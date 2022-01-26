-- local java_language_server = require "java_language_server"
return {
  settings = {
    java = {
      home = "/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home",
      eclipse = {
        downloadSources = true,
      },
      server = {
        launchMode = "Hybrid",
      },
      configuration = {
        maven = {
          userSettings = "/opt/software/apache-maven-3.6.3/conf/settings.xml",
          globalSettings = "/opt/software/apache-maven-3.6.3/conf/settings.xml",
        },
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home",
          },
          {
            name = "JavaSE-11",
            path = "/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home",
          },
        }
      },
    }
  }
}
