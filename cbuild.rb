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

def buildProject(projectDir)
  abort("CMake failure") unless system("cmake #{projectDir}")
  abort("Make failure") unless system("make")
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

  buildProject(srcPath)
end

main()
