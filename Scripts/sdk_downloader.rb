require 'fileutils'

class SDKDownloader
  def initialize
    @sdk_dir = File.expand_path(File.join(File.dirname(__FILE__), "../AdNetworkSupport"))
    @tmp_dir = File.expand_path(File.join(File.dirname(__FILE__), "tmp_sdk"))
    FileUtils.rm_rf(@tmp_dir)
    FileUtils.mkdir_p(@tmp_dir)
  end

  def download!
    download_chartboost
    download_admob
    download_greystripe
    download_inmobi
    download_millennial

    tear_down_tmp_dir
  end

  def tear_down_tmp_dir
    FileUtils.rm_rf(@tmp_dir)
  end

  def head(text)
    puts "\n*** #{text} ***"
  end

  def log(text)
    puts "    #{text}"
  end

  def run(cmd)
    system(cmd) or begin
      puts "******** SDK Download Failed ********"
      exit(1)
    end
  end

  def download(url, file)
    log "Downloading #{file}..."
    run("curl --progress-bar -L #{url} > #{File.join(@tmp_dir, file)}")
  end

  def extract_tar_bz2(file)
    log "Extracting #{file}..."
    run("bunzip2 #{File.join(@tmp_dir, file)}")
    run("tar -xf #{File.join(@tmp_dir, File.basename(file, ".bz2"))} -C #{@tmp_dir}")
  end

  def extract_zip(file)
    log "Extracting #{file}..."
    run("unzip #{File.join(@tmp_dir, file)} -d #{@tmp_dir}")
  end

  def copy_sdk(sdk, source_directory)
    log "Copying #{sdk}..."
    destination_directory= File.join(@sdk_dir, sdk, 'SDK')
    FileUtils.mkdir_p(destination_directory)
    run("rm -rf #{destination_directory}/*.h")
    run("rm -rf #{destination_directory}/*.a")
    run("cp #{@tmp_dir}/#{source_directory}/*.h #{destination_directory}")
    run("cp #{@tmp_dir}/#{source_directory}/*.a #{destination_directory}")
  end

  def download_chartboost
    head "Chartboost"
    download("https://dashboard.chartboost.com/support/sdk_download/?os=ios", "Chartboost.tar.bz2")
    extract_tar_bz2("Chartboost.tar.bz2")
    copy_sdk("Chartboost", "Chartboost")
  end

  def download_admob
    head "GoogleAdMob"
    download("http://dl.google.com/googleadmobadssdk/googleadmobadssdkios.zip", "admob.zip")
    extract_zip("admob.zip")
    copy_sdk("GoogleAdMob", "GoogleAdMobAdsSdkiOS-*")
  end

  def download_greystripe
    head "Greystripe"
    download("https://github.com/greystripe/greystripe-ios-sdk/archive/master.zip", "greystripe.zip")
    extract_zip("greystripe.zip")
    copy_sdk("Greystripe", "greystripe-ios-sdk-*/GreystripeSDK")
  end

  def download_inmobi
    head "InMobi"
    download("https://www.inmobi.com/AdvancedAdCode/InMobi_iOS_SDK.zip", "inmobi.zip")
    extract_zip("inmobi.zip")
    copy_sdk("InMobi", "InMobi_iOS_SDK_*/Libs")
  end

  def download_millennial
    head "The Millennial Media SDK requires a login at http://mmedia.com/resources/sdk-api/"
  end
end