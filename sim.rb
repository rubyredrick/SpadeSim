require 'lib/simulator.rb'
if (arg = ARGV.first)
  min_wins = arg.to_i
  puts "Running until each club has won at least #{min_wins} times"
  Simulator.new(min_wins).run
else
  puts <<END_OF_HELP
The simulator requires a single integer argument which determines when to end the simulation.

The simulation runs until each club has won at least the number of times given by the argument
END_OF_HELP
end 