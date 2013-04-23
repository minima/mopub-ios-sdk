class NetworkTesting
  def run_with_proxy
    pid = fork do
      exec "#{File.join(File.dirname(__FILE__))}/proxy.rb"
    end

    begin
      yield
    rescue SystemExit => e
      exit(1)
    ensure
      Process.kill 'INT', pid
      Process.wait pid
    end
  end

  def head(text)
    puts "\n########### #{text} ###########"
  end

  def network_calls
    @network_calls = @network_calls || File.readlines("#{File.join(File.dirname(__FILE__))}/proxy.log")
  end

  def verify_kif_log_lines(kif_log_lines)
    head "Verifying Conversion Tracking"
    verify_presence_of_url("Conversion Tracking", /http:\/\/ads.mopub.com\/m\/open\?v=\d&udid=[A-Za-z0-9_\-\:]+&id=112358&av=1\.0$/)
    verify_presence_of_url("Foreground Tracking", /http:\/\/ads.mopub.com\/m\/open\?v=\d&udid=[A-Za-z0-9_\-\:]+&id=com\.mopub\.SampleAppKIF&av=1\.0&st=1$/)

    head "Verifying KIF Impressions"
    verify_kif_impressions(kif_log_lines)

    head "Verifying KIF Clicks"
    verify_kif_clicks(kif_log_lines)
  end

  def ids_matching_matcher(lines, matcher)
    ids = []
    lines.each do |line|
      match = matcher.match(line)
      ids << match[1] if match
    end
    ids
  end

  def verify_match(a, b, kind)
    if a == b
      puts "******** NETWORK TEST #{kind} SUCCEEDED (#{b.length}/#{a.length}) ********"
    else
      puts "******** NETWORK TEST #{kind} FAILED ********"
      puts "Expected                         Received"
      count = [a.length, b.length].max
      (0...count).each do |i|
        puts "#{a[i]} #{b[i]}"
      end

      exit(1)
    end
  end

  def verify_presence_of_url(kind, regex)
    matches = ids_matching_matcher(network_calls, regex)
    if matches.count == 0
      puts "******** NETWORK TEST #{kind} FAILED (expected #{regex}) ********"
      exit(1)
    else
      puts "******** #{kind} SUCCEEDED ********"
    end
  end

  def verify_kif_impressions(kif_lines)
    kif_ad_ids = ids_matching_matcher(kif_lines, /~~~ EXPECT IMPRESSION FOR AD UNIT ID: ([A-Za-z0-9_\-]+)/)
    proxy_ad_ids = ids_matching_matcher(network_calls, /http:\/\/ads.mopub.com\/m\/imp\?.*&id=([A-Za-z0-9_\-]+)&/)
    verify_match(kif_ad_ids, proxy_ad_ids, "IMPRESSIONS")
  end

  def verify_kif_clicks(kif_lines)
    kif_ad_ids = ids_matching_matcher(kif_lines, /~~~ EXPECT CLICK FOR AD UNIT ID: ([A-Za-z0-9_\-]+)/)
    proxy_ad_ids = ids_matching_matcher(network_calls, /http:\/\/ads.mopub.com\/m\/aclk\?.*&id=([A-Za-z0-9_\-]+)&/)
    verify_match(kif_ad_ids, proxy_ad_ids, "CLICKS")
  end
end