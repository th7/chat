require 'socket'

host = 'localhost'
port = 8134

s = TCPSocket.open(host, port)

Thread.start do
  while line = s.gets
    puts line.chop
  end
end

loop do
  s.puts gets
end
