#!/usr/bin/env ruby

#Add to your sudoers file:
#USERNAME ALL=NOPASSWD:/usr/sbin/networksetup
#where USERNAME is the user that will be running this script

require 'webrick/httpproxy'
require 'stringio'

networks = ['Wi-Fi', 'Ethernet']

networks.each do |network|
  puts "Starting proxy on #{network}"
  `sudo networksetup -setwebproxy #{network} 127.0.0.1 9999 off`
  `sudo networksetup -setwebproxystate #{network} on`
end

$stderr = StringIO.new

file_path = File.join(File.dirname(__FILE__), 'proxy.log')
f = File.open(file_path, 'w')

handler = Proc.new do |req,res|
  path = req.request_uri.to_s
  time = Time.now.strftime('%F %H:%M:%S.%L')
  f << "#{time} #{path}\n"
end

s = WEBrick::HTTPProxyServer.new(:Port => 9999, :RequestCallback => handler);
trap("INT") { s.shutdown }
s.start

at_exit do
  f.close
  networks.each do |network|
    puts "Stopping proxy on #{network}"
    `sudo networksetup -setwebproxystate #{network} off`
  end
end