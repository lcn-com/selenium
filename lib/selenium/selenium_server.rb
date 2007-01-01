require 'net/http'

module Selenium

# Selenium server driver that provides API to start/stop server and check if 
# server is running.
# NOTE: The start does not return until the server shuts down.
class SeleniumServer
  def SeleniumServer::run(argv)
    jar_file = SeleniumServer.jar_file
    command = "java -jar #{jar_file} #{argv.join(' ')}"
    puts command
    system(command)
  end
  
  private
  def SeleniumServer::jar_file
    File.join(File.dirname(__FILE__), 'openqa', 'selenium-server.jar.txt')
  end
  
  public
  attr_reader :port_number

  # Initialize the server driver with an opitonal port number (default to 4444)
  def initialize(port_number = 4444)
    @port_number = port_number
  end
  
  # Starts the Selenium server.  This does not return until the server is shutdown.
  def start
    SeleniumServer.run(['-port', port_number.to_s])
  end
  
  # Stops the Selenium server
  def stop
    Net::HTTP.get('localhost', '/selenium-server/driver/?cmd=shutDown', @port_number)
  end
  
  # Check if the Selenium is running by sending a test_complete command with invalid session ID
  def running?
    url = URI.parse("http://localhost:#{@port_number}/selenium-server/driver/?cmd=testComplete&sessionId=smoketest")
    request = Net::HTTP::Get.new(url.path)
    begin
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.read_timeout=5
        http.request(request)
      }
      puts "response: #{res}"
    rescue Errno::EBADF => e
      return false
    end 
    return true      
  end
end
end