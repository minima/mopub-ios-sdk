require 'rubygems'
require 'tmpdir'
require 'timeout'
require 'pp'
require 'fileutils'
require './Scripts/screen_recorder'
require './Scripts/network_testing'
require './Scripts/sdk_downloader'

puts ENV["PATH"]
ENV["PATH"] += ":/usr/local/bin"

if File.exists?('./Scripts/private/private.rb')
  require './Scripts/private/private.rb'
end

CONFIGURATION = "Debug"
BUILD_DIR = File.join(File.dirname(__FILE__), "build")

class Simulator
  def initialize(options)
    sdk_version = options[:sdk] || available_sdk_versions.max
    @ios_sim_device_id = "com.apple.CoreSimulator.SimDeviceType.iPhone-5s, #{sdk_version}"
  end

  # We no longer have a way to reset the simulator, so if tests start to fail for no good reasons,
  #   a manual reset may be necessary

  def run(app_location, env)
    env_vars = env.map { |k,v| "--setenv #{k}=#{v}" }
    cmd = "ios-sim launch #{app_location} #{env_vars.join(" ")} --devicetypeid \"#{@ios_sim_device_id}\""
    IO.popen(cmd) { |io| while (line = io.gets) do puts line end }
  end
end

def head(text)
  puts "\n########### #{text} ###########"
end

def clean!
  `rm -rf #{BUILD_DIR}`
end

def build_dir(effective_platform_name)
  File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def output_file(target)
  output_dir = File.join(File.dirname(__FILE__), "build")
  FileUtils.mkdir_p(output_dir)
  File.join(output_dir, "#{target}.output")
end

def system_or_exit(cmd, outfile = nil)
  cmd += " > #{outfile}" if outfile
  puts "Executing #{cmd}"

  system(cmd) or begin
    puts "******** Build Failed ********"
    puts "To review:\ncat #{outfile}" if outfile
    exit(1)
  end
end

def build(options)
  clean!
  target = options[:target]
  configuration = options[:configuration] || CONFIGURATION
  if options[:destination]
    destination = "-destination #{options[:destination]}"
  else
    destination = ""
  end

  if options[:sdk]
    sdk = options[:sdk]
  elsif options[:sdk_version]
    sdk = "iphonesimulator#{options[:sdk_version]}"
  else
    sdk = "iphonesimulator#{available_sdk_versions.max}"
  end
  out_file = output_file("mopub_#{options[:target].downcase}_#{sdk}")

  if target == "MoPubSDKTests"
    workspace = options[:workspace]
    system_or_exit(%Q[xcodebuild -workspace #{workspace}.xcworkspace -scheme #{target} -configuration #{configuration} ARCHS=i386 #{destination} -sdk #{sdk} test SYMROOT=#{BUILD_DIR}], out_file)    
  elsif options[:workspace]
    workspace = options[:workspace]
    system_or_exit(%Q[xcodebuild -workspace #{workspace}.xcworkspace -scheme #{target} -configuration #{configuration} ARCHS=i386 #{destination} -sdk #{sdk} build SYMROOT=#{BUILD_DIR}], out_file)
  else
    project = options[:project]
    system_or_exit(%Q[xcodebuild -project #{project}.xcodeproj -target #{target} -configuration #{configuration} ARCHS=i386 #{destination} -sdk #{sdk} build SYMROOT=#{BUILD_DIR}], out_file) 
  end
end

def available_sdk_versions
  available = []
  `xcodebuild -showsdks | grep iphonesimulator`.split("\n").each do |line|
    match = line.match(/simulator([\d\.]+)/)
    # excluding 5.* SDK and 6.* versions
    available << match[1] if match and !match[1].start_with? "5." and !match[1].start_with? "6."
  end
  available
end

desc "Build MoPubSDK on all SDKs then run tests"
task :default => [:trim_whitespace, "mopubsdk:build", "mopubsample:build", "mopubsdk:unittest"] 

desc "Run all unit tests"
task :unittest => ["mopubsdk:unittest"]

desc "Run KIF integration tests"
task :integration_specs => ["mopubsample:kif"]

desc "Trim Whitespace"
task :trim_whitespace do
  head "Trimming Whitespace"

  system_or_exit(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") for (i=2; i<=NF; i++) printf("%s%s", $i, i<NF ? " " : ""); print ""}' | grep -e '.*.[mh]"*$' | xargs sed -i '' -e 's/	/    /g;s/ *$//g;'])
end

desc "Download Ad Network SDKs"
task :download_sdks do
  head "Downloading Ad Network SDKs"
  downloader = SDKDownloader.new
  downloader.download!
end

namespace :mopubsdk do
  desc "Build MoPub SDK against all available SDK versions"
  task :build do
    available_sdk_versions.each do |sdk_version|
      head "Building MoPubSDK for #{sdk_version}"
      build :project => "MoPubSDK", :target => "MoPubSDK", :sdk_version => sdk_version
    end

    available_sdk_versions.each do |sdk_version|
      head "Building MoPubSDK+Networks for #{sdk_version}"
      build :project => "MoPubSDK", :target => "MoPubSDK+Networks", :sdk_version => sdk_version
    end
    
    head "SUCCESS"
  end

  desc "Run unit tests with specified iOS Simulator using argument 'simulator_version'"
  task :unittest do

    simulator_version = ENV['simulator_version']
    if (!simulator_version)
      simulator_version = available_sdk_versions.max
    end

    head "Running unit tests in iOS Simulator version #{simulator_version}"
    build :workspace => "MoPubSDK", :target => "MoPubSDKTests", :destination => "'platform=iOS Simulator,name=iPad'"

    head "SUCCESS"
  end
end

namespace :mopubsample do
  desc "Build MoPub Sample App"
  task :build do
    head "Building MoPub Sample App"
    build :project => "MoPubSampleApp", :target => "MoPubSampleApp"
  end
end

desc "Run jasmine specs"
task :run_jasmine do
  head "Running jasmine"
  Dir.chdir('Specs/JasmineSpecs/SpecsApp') do
    # NOTE: for this task to run, you must have already run 'npm install' in the Jasminespecs/SpecsApp dir
    # test runner is in a node app that requires the mraid.js file to be in a specific path
    system_or_exit(%Q[cp ../../../MoPubSDK/Resources/MRAID.bundle/mraid.js webapp/static/vendor/mraid.js])
    begin
        system_or_exit(%Q[node node_modules/jasmine-phantom-node/bin/jasmine-phantom-node webapp/static/tests])
    ensure
        system_or_exit(%Q[rm webapp/static/vendor/mraid.js])
    end
  end
end