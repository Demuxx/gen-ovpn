#!/usr/bin/env ruby
require 'erb'
require 'socket'
require 'optparse'
require 'pp'

OptionParser.new do |opt|
  opt.banner = "Usage: ovpngen.rb [options]"
  opt.on("-e", "--easy-rsa-dir DIRECTORY", "The location of the easy-rsa binary") { |o| o.nil? ? @easy_rsa = "/etc/easyrsa" : @easy_rsa = o }
  opt.on("-k", "--pki-dir DIRECTORY", "The location of the pki directory for easy-rsa") { |o| o.nil? ? @pki = "/etc/easyrsa/pki" : @pki = o }
  opt.on("-c", "--client-name CLIENTNAME", "The human readable name for the openvpn client") { |o| o.nil? ? @client_name = "client" : @client_name = o }
  opt.on("-s", "--server SERVER", "The DNS or IP address of the openvpn server") { |o| o.nil? ? @server = Socket.ip_address_list.select{ |ip| ip.ip_unpack.first != "127.0.0.1" }.first.ip_unpack.first : @server = o }
  opt.on("-p", "--port PORT", "The port of the openvpn server") { |o| o.nil? ? @port = "1194" : @port = o }
  opt.on("-P", "--proto PROTO", "The protocol (tcp or udp) of the openvpn server") { |o| o.nil? ? @proto = "udp" : @proto = o }
  opt.on("-h", "--help", "Prints this help") { puts opt; exit }
end.parse!

`#{@easy_rsa}/easyrsa build-client-full #{@client_name} nopass`

@ca = File.read("#{@pki}/ca.crt").chomp("\n")
@dh = File.read("#{@pki}/dh.pem").chomp("\n")
@key = File.read("#{@pki}/private/#{@client_name}.key").chomp("\n")
@cert = File.read("#{@pki}/issued/#{@client_name}.crt").chomp("\n")

template = ERB.new(File.read("#{File.dirname(__FILE__)}/ovpngen.ovpn.erb"))
output = File.open("#{@client_name}.ovpn", "w")
output << template.result
output.close
