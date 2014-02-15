require 'rubygems'
require_relative '../messages/controller.pb'
require 'ffi-rzmq'

def error_check(rc)
  if ZMQ::Util.resultcode_ok?(rc)
    false
  else
    STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    caller(1).each { |callstack| STDERR.puts(callstack) }
    true
  end
end

class WelcomeController < ApplicationController
  @@socket = nil
  def initialize
    super
    if nil == @@socket
      ctx = ZMQ::Context.new
      @@socket = ctx.socket ZMQ::PUSH
      @@socket.setsockopt(ZMQ::LINGER, 1)
      rc = @@socket.connect("tcp://192.168.1.40:9000")
      error_check(rc)
      puts "Socket created"
    end
  end
    
  def index
    data = params[:data]
    print "BATMAN goes ", data, "\n"
    left = 0
    right = 0
    fire_weapon1 = false
    fire_weapon2 = false
    if ("LEFT" == data)
      left = -1
      right = 1
    elsif ("FORWARD" == data)
      left = 1
      right = 1
    elsif ("RIGHT" == data)
      left = 1
      right = -1
    elsif ("BACKWARD" == data)
      left = -1
      right = -1
    end
    if left != 0
      input = Orwell::Messages::Input.new(
	:move => Orwell::Messages::Input::Move.new(
	  :left => left,
	  :right => right),
	:fire => Orwell::Messages::Input::Fire.new(
	  :weapon1 => fire_weapon1,
	  :weapon2 => fire_weapon2))
      print "input = '", input.to_json, "'\n"
      bytes = input.to_s
      zmq_message = "TANK_0 Input " + bytes
      print "bytes = '" + bytes.inspect + "'\n"
      @@socket.send_string(zmq_message)
      print "zmq_message = '" + zmq_message + "'\n"
    end
  end
end
