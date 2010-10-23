require 'lib/simulator.rb'
if (arg    = ARGV.first)
  begin
    max_hands = Integer(arg)
    puts "Playing #{max_hands} hands"
    Simulator.new(max_hands).run
  rescue ArgumentError
    puts <<-END_OF_HELP
usage
sim n

runs the simulation for n hands

sim

if n is omitted then the simulation will run until each club wins at least once
  This can take a long time, since the 2 of clubs will only win if a player is dealt a
  hand of all clubs
END_OF_HELP
  end
else
  puts "Running without specifying a maximum number of hands takes a long time."
  puts "Are you sure? (yN)."
  if gets.chomp.downcase == 'y'
    Simulator.new.run
  end
end 