require 'socket'
require 'thread'

server = TCPServer.open(8134)

output = Queue.new
input = Queue.new
clients = {}

Thread.start do
  loop do
    Thread.start(server.accept) do |socket|
      socket.puts 'Enter your name: '
      name = socket.gets.chomp
      puts "#{name} connected"
      socket.puts "Welcome #{name}!"
      clients[name] = socket
      output << {:name => 'server', :text => "#{name} connected"}
      loop do
        got = socket.gets
        if got
          input << {:name => name, :text => got}
        else
          puts "#{name} disconnected"
          output << {:name => 'server', :text => "#{name} disconnected"}
          clients.delete(name)
          socket.close
          break
        end
      end
    end
  end
end

Thread.start do
  loop do
    msg = output.pop
    clients.each do |n, s|
      s.puts "#{msg[:name]}: #{msg[:text]}" unless n == msg[:name]
    end
  end
end

Thread.start do
  loop do
    msg = input.pop
    puts "#{msg[:name]}: #{msg[:text]}"
    output << msg
  end
end

begin
  loop do
    output << {:name => 'server', :text => gets}
  end
ensure
  clients.each { |n, s| s.close }
end
