#
# A simple radio script to get started
# Filenames need to be edited in playlist() and single() sources
#

set("log.file.path","/tmp/liquidsoap.log") # путь к файлу лога
set("log.level", 4) # уровень логирования
set("server.telnet", true)

# fix delay on telnet
##set("frame.size",940)

#### transition between musics
def changemusic(a,b)
  add(normalize=false,
      [ sequence([ blank(duration=50.),
                   fade.initial(duration=100.,b) ]),
        fade.final(duration=100.,a) ])
end


#### say balance with google
iBalance = interactive.string("balance","1234456,78")
def gtts_say() = 
  # Get the first line of my external process
  result = list.hd(get_process_lines("/usr/scripts/liquidsoap/gtts.sh "^iBalance()))
  # Create and return a request using this result
  request.create(result)
end

# Create the source
sBalance = once(request.dynamic(gtts_say))

#message =
#  "The Savonet team thanks you for using liquidsoap, " ^
#  "and we hope you'll enjoy it!"

# Then we setup our icecast output function.
# Possible options and values are bitrate=64, samplerate=11025, ...
#out = output.icecast(%vorbis,host="localhost")

#input = "input.mp3"

# A source that plays the file once
#sMusic1 = single("/usr/scripts/liquidsoap/mono2.mp3")
sMusic1 = single("/usr/scripts/liquidsoap/mono-8000.wav", length=1.)
sMusic2 = single("/usr/scripts/liquidsoap/mono2-8000.wav", length=1.)
sMusic3 = single("/usr/scripts/liquidsoap/mono3-8000.wav", length=1.)

# Create an interactive boolean
#b = interactive.bool("button", true)
iMusic = interactive.string("music","music1")
iSaybalance = interactive.bool("saybalance",false)

# Switch between the tracks depending on the boolean
#s = mksafe(switch(track_sensitive=false,[({"music1" == b()},s1), ({b() == "music2"},s2)]))
sResult = mksafe(
	switch(track_sensitive=false,
	transitions=[changemusic],
	[
		({"music1" == iMusic()},sMusic1),
		({"music2" == iMusic()},sMusic2),
		({"music3" == iMusic()},sMusic3),
	])
)
#clock.assign_new(sync=false,[sResult])

#sResult = smooth_add(normal=sResult, special=switch([(iSaybalance, sBalance)]))
sResult = add([sResult, switch([(iSaybalance, sBalance)])],weights=[1,2])
#s = switch(track_sensitive=false,[(b,s1), ({true},s2)])

# We use a clock with disabled synchronization
# disable delay before play
#clock.assign_new(sync=false,[sResult])
#out = output.file(%external(header=false, channels=1, samplerate=8000, process="/bin/cat"), "/dev/stdout", sResult)
#out = output.external(%wav(header=false, channels=1, samplerate=8000), "/bin/cat", sResult)
#out = output.file(%wav(header=false, channels=1, samplerate=8000), "/dev/stdout", sResult, flush=true)
out = output.file(%wav(header=true, channels=1, samplerate=8000), "/dev/stdout", sResult, flush=true)
#out = output.udp(%wav(header=true, channels=1, samplerate=8000), host='127.0.0.1', port=1235, sResult)
#out = output.udp(%vorbis(samplerate=44100, channels=1, quality=0.3), host='192.168.0.77', port=1235, sResult)
#out = output.udp(%mp3(mono), host='192.168.0.77', port=1235, sResult)
#out = output.external(ernal(header=false, channels=1, samplerate=8000, process="/bin/cat"), sResult)


#out( #source="demo.ogg") #,
  # The scheduler plays a randomized playlist, or the .ogg file
  # if the playlist fails to stream anything. The playlist can be made
  # of remote URIs.
#out(  add([
#    # Comment out the next line if you don't have speech synthesis enabled.
#    delay(10.,single("say:"^message)),
#    # We add another output without the synthesized messages. It is not started
#    # but you can turn it on using the server:
#    # > telnet localhost 1234
#    # > novoice.ogg.start
#    out(start=false,mount="novoice.ogg",
#        fallback([ playlist("/your/favorite.m3u"),
#                   # The out(..) needs the single(..) to be infallible,
#                   # which requires a valid audio filename.
#                   single("/some/file.ogg") ]))
#    ],
#    weights=[5,1]))
