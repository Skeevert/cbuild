#!/bin/ruby

require 'fileutils'

def userAgrees?(prompt)
  $stdout.print("#{prompt} [y/n]: ")
  result = gets().chomp().downcase()
  return result == "y"
end

def processBuildDir(buildPath)
  unless File.directory?(buildPath)
    exit(0) unless userAgrees?("#{buildPath} does not exist. Create?")
    Dir.mkdir(buildPath)
  end
end

def invokeMetaBuild(projectPath, buildPath)
  metaBuilder = nil
  metaBuilder = "qmake" unless Dir.glob("*.pro", base: projectPath).empty?()
  metaBuilder = "cmake" if File.exist?(File.join(projectPath, "CMakeLists.txt"))

  puts(metaBuilder)
  
  unless metaBuilder.nil?()
    abort("Meta build failure") unless system("#{metaBuilder} #{projectPath}")
    return
  end

  # We didn't find any known metabuild system. But maybe there's no metabuild system
  # Let's just prepare for building
  puts("Cannot find any metabuild system. Trying to build without")

  projectFiles = Dir.glob("*", base: projectPath).map do |name|
    File.join(projectPath, name)
  end

  FileUtils.cp_r(projectFiles, File.join(buildPath, "."))
end

def buildProject(buildPath)
  builder = nil
  builder = "make" if File.exist?(File.join(buildPath, "Makefile"))

  unless builder.nil?()
    abort("Make failure") unless system(builder)
    return
  end

  abort("Cannot determine used build system")
end

def main()
  srcPath = Dir.pwd()
  projectName = File.basename(srcPath)

  baseBuildPath = File.join(ENV["HOME"], "builds")
  processBuildDir(baseBuildPath)

  buildPath = File.join(baseBuildPath, projectName)
  Dir.mkdir(buildPath) unless File.directory?(buildPath)

  Dir.chdir(buildPath)

  # Cleaning
  # TODO: make this action optional
  # FileUtils.rm_rf(File.join(buildPath, "."), verbose: true, secure: true)

  invokeMetaBuild(srcPath, buildPath)
  buildProject(buildPath)

end

main()
