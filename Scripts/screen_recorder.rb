class ScreenRecorder
  def initialize(path)
    @path = path
  end

  def run_applescript(applescript)
    path_to_applescript = File.expand_path(File.join(File.dirname(__FILE__), applescript))
    `osascript #{path_to_applescript}`
  end

  def start_recording
    run_applescript "start_recording.applescript"
  end

  def save_recording
    video_file_name = "RECORDING_#{Time.new.strftime("%Y_%m_%d_%H_%M")}.mov"
    video_path = File.join(@path, video_file_name)

    run_applescript "stop_and_save_recording.applescript #{video_path}"

    video_file_name
  end

  def stop_recording
    run_applescript "stop_recording.applescript"
  end
end