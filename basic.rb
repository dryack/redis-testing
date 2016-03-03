require 'redis'
require 'json'
require 'stackprof'
require 'benchmark'

class StoredMsg < Struct.new(:time, :who, :message)
  def to_s
    "[#{time.strftime('%m/%d %I:%M%p')}] <#{who}> #{message}"
  end
end

def fake_messages
  users = %w(w80 jig rathburn coolio)
  messages = %w("screw you" "hell no" "i don't have to listen to this crap")
  StoredMsg.new(Time.now, users.sample, messages.sample)
end

def add_msg(storedmsg)
  $storedmsg = storedmsg
  $redis.rpush 'messages', $storedmsg.to_json
  $redis.ltrim('messages', -100, -1)
  # if $redis.llen("messages").to_i > 100
  #   $redis.ltrim("messages", 1, -1)
  # end
  $storedmsg = {}
end

StackProf.run(mode: :cpu, interval: 1000, out: 'stackprof-cpu-redis-test.dump') do
  $weee=0
  $redis = Redis.new(:db => 2)
  $storedmsg = {}

  puts Benchmark.measure { 5000.times do
    add_msg(fake_messages)
  end
  }
end

# fifteen = $redis.lrange("messages", "-100","100")
# fifteen.each {|msg_num| print msg_num}