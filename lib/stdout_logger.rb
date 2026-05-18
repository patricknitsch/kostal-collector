class StdoutLogger
  def initialize
    $stdout.sync = true
  end

  def info(message, newline: true)
    if newline
      puts message
    else
      print message
    end
  end

  def error(message)
    puts "\e[31m#{message}\e[0m"
  end
end
