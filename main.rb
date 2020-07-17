require 'mastodon'
require 'pry'
require 'digest'
require 'open3'

class Bot
  def run
    client = Mastodon::REST::Client.new(base_url: ENV['SERVER_URL'], bearer_token: ENV["ACCESS_TOKEN"])
    checkpoint = File.open("checkpoint", "a+")
    current=checkpoint.read.split.last
    puts "reading"
    found = false
    unread = client.conversations.collect do |conv|
      found = true if conv.id == current
      next if found
      conv
    end.compact
    unread.each do |unr|
      puts "Found #{unr.id}"
      process_conversation(unr)
    end
    checkpoint.puts unread.first.id if unread.any?
  end

  def fundme(conv, com)
    @output = nil
    cmd = `clw #{Digest::MD5.hexdigest(conv.attributes["accounts"].first["acct"])}`
    puts 'start command'
#    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
 #     puts 'doin'
 #     stdin.puts "y"
 #     stdin.puts "yes"
 #     @output = stdout.read
 #     puts "DONE"
  #  end

    puts "--> #{@output}"
    puts "Funding requested"
  end

  def donate(conv, com)
    puts "Donation made"
  end

  def cashout(conv, com)
    puts "Cashout requested"
  end

  def error_response(conv)
    puts "ERROR!"
  end

  def process_conversation(conversation)
    puts 'processing conversation'
    command = conversation.attributes["last_status"]["content"].gsub(/<\/?[^>]*>/, "").gsub(/^@\w*\s/, "")
    case command
    when "fundme"
      fundme(conversation, command)
    when /donate/
      donate(conversation, command)
    when /cashout/
      cashout(conversation, command)
    else
      error_response(conversation)
    end
  end
end

Bot.new.run
