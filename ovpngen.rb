#!/usr/bin/env ruby
require 'erb'
require 'socket'
require 'optparse'

options = {
  easy_rsa:	"/etc/easyrsa",
  pki:		"/etc/easyrsa/pki",
  client_name: 	"client", 
  port: 	"1194", 
  proto: 	"udp", 
  server: 	Socket.ip_address_list.select{ |ip| ip.ip_unpack.first != "127.0.0.1" }.first.ip_unpack.first 
}

OptionParser.new do |opt|
  opt.banner = "Usage: ovpngen.rb [options]"
  opt.on("-e", "--easy-rsa-dir", "The location of the easy-rsa binary") { |o| options[:easy_rsa] = o }
  opt.on("-k", "--pki-dir", "The location of the pki directory for easy-rsa") { |o| options[:pki] = o }
  opt.on("-c", "--client-name", "The human readable name for the openvpn client") { |o| options[:client_name] = o }
  opt.on("-s", "--server", "The DNS or IP address of the openvpn server") { |o| options[:server] = o }
  opt.on("-p", "--port", "The port of the openvpn server") { |o| options[:port] = o }
  opt.on("-P", "--proto", "The protocol (tcp or udp) of the openvpn server") { |o| options[:proto] = o }
  opt.on("-h", "--help", "Prints this help") { puts opt; exit }
end.parse!

`#{options[:easy_rsa]}/easyrsa build-client-full #{options[:client_name]} nopass`

@ca = File.read("#{options[:pki]}/ca.crt").chomp("\n")
@dh = File.read("#{options[:pki]}/dh.pem").chomp("\n")
@key = File.read("#{options[:pki]}/private/#{options[:client_name]}.key").chomp("\n")
@cert = File.read("#{options[:pki]}/issued/#{options[:client_name]}.crt").chomp("\n")

template = ERB.new(File.read("ovpngen.ovpn.erb"))
output = File.open("#{options[:client_name]}.ovpn", "w")
output << template.result
output.close
