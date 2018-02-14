#!/usr/bin/env ruby
require 'erb'
require 'socket'
require 'optparse'

options = {
  client_name: 	"client", 
  port: 	"1194", 
  proto: 	"udp", 
  server: 	Socket.ip_address_list.select{ |ip| ip.ip_unpack.first != "127.0.0.1" }.first.ip_unpack.first 
}

OptionParser.new do |opt|
  opt.banner = "Usage: ovpngen.rb [options]"
  opt.on("-c", "--client_name", "The human readable name for the openvpn client") { |o| options[:client_name] = o }
  opt.on("-s", "--server", "The DNS or IP address of the openvpn server") { |o| options[:server] = o }
  opt.on("-p", "--port", "The port of the openvpn server") { |o| options[:port] = o }
  opt.on("-P", "--proto", "The protocol (tcp or udp) of the openvpn server") { |o| options[:proto] = o }
  opt.on("-h", "--help", "Prints this help") { puts opt; exit }
end.parse!

`/etc/openvpn/easy-rsa/easyrsa build-client-full #{options[:client_name]} nopass`

@ca = File.read("/etc/easyrsa/pki/ca.crt").chomp("\n")
@dh = File.read("/etc/easyrsa/pki/dh.pem").chomp("\n")
@key = File.read("/etc/easyrsa/pki/private/#{options[:client_name]}.key").chomp("\n")
@cert = File.read("/etc/easyrsa/pki/issued/#{options[:client_name]}.crt").chomp("\n")

template = ERB.new(File.read("ovpngen.ovpn.erb"))
output = File.open("#{options[:client_name]}.ovpn", "w")
output << template.result
output.close
