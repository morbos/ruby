#! /usr/bin/ruby

require 'pi_piper'

include PiPiper

$sema = Mutex.new
$fpath = "./"
$glopid = 0
$record = 0
$motion_seen = 0
#$pin = 14
$pin = 18
# When RPi GPIO[$pin] becomes 1, start the recorder
def motion_detect
  after :pin => $pin, :goes => :high do
    # get the time for this motion
    $sema.synchronize {     
#      time1 = Time.new
      $record += 1
      $motion_seen = 1
      printf "%s(%d)@%s\n","Motion", $record, Time.now
      Process.kill("SIGCONT", $glopid)
    }
  end
end

# start the raspivid and pass an arg to enable SIGCONT/SIGSTOP

def vid_init
  # time stamp for this run
  time1 = Time.now
  fname = ""
  fname = "vid_" + time1.strftime("%Y-%m-%d_%H_%M_%S") + ".h264"
  # This is a continuous video stream w/signal support.
  # it can be stopped and started via signals (CONT and STOP)
#  str = "raspivid" + " -vf -s -w 640 -h 480 -t 0 -o " + $fpath + fname
  str = "raspivid" + " -s -w 1296 -h 730 -t 0 -o " + $fpath + fname
  $glopid = Process.fork do
    Process.exec(str);
  end
  Process.kill("SIGSTOP", $glopid)
  Process.wait
end

# Keep the recording going 5 seconds after cessation of motion
def record_while_motion
   lsleep = 0
   while true do
     $sema.synchronize {
      if $record != 0
        $record -= 1
        lsleep = 1
      elsif 1 == $motion_seen
        Process.kill("SIGSTOP", $glopid)
        $motion_seen = 0
      end
    }
     if lsleep
       sleep(5)
       lsleep = 0
     end
   end
end

# start raspivid thread
vi=Thread.new{vid_init()}

# start GPIO thread
md=Thread.new{motion_detect()}

# Keep recording on motion
rm=Thread.new{record_while_motion()}

vi.join
mi.join
rm.join

PiPiper.wait

