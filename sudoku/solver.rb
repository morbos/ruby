#!/usr/bin/ruby
# sudoku solver.
# input file is as so: (sdk1.inp)
# 436010002
# 800354600
# 001020000
# 503080020
# 104000503
# 020030106
# 000070400
# 009841005
# 300090871
#
# occupied squares are 1-9, 0 is empty
# solver.rb sdk1.inp
# ...
# Solution
# [4, 3, 6, 7, 1, 8, 9, 5, 2]
# [8, 9, 2, 3, 5, 4, 6, 1, 7]
# [7, 5, 1, 9, 2, 6, 3, 4, 8]
# [5, 6, 3, 1, 8, 9, 7, 2, 4]
# [1, 8, 4, 2, 6, 7, 5, 9, 3]
# [9, 2, 7, 4, 3, 5, 1, 8, 6]
# [2, 1, 8, 5, 7, 3, 4, 6, 9]
# [6, 7, 9, 8, 4, 1, 2, 3, 5]
# [3, 4, 5, 6, 9, 2, 8, 7, 1]

require 'set'

if(ARGV.length != 1)
  printf "solver: infile\n"
  exit(1)
end

$fs = Set.new([1,2,3,4,5,6,7,8,9])

def print_board(b)
  for row in 0..8 do
    print b[row].flatten,"\n" # Not sure flatten is needed here
  end
end  
def print_set(n,s)
  puts n
  for i in 0..8 do
    print i,":"
    s[i].each { |x| print x, ' '}
    print "\n"
  end
end

def move(b,rs,cs,bs,level)
  choices = Hash.new  
  # Initially, rs,cs,bs are all nil.
  # rs = row set
  # cs = col set
  # bs = block set
  # all these sets need to have the vals 1..9 to be complete.
  # We build 9 sets for each row, col and block which completes
  # the 9x9 layout
  if rs == nil
    rs = Array.new(9)
    for i in 0..8 do
      rs[i] = Set.new
    end
    cs = Array.new(9)
    for i in 0..8 do
      cs[i] = Set.new
    end
    bs = Array.new(9)
    for i in 0..8 do
      bs[i] = Set.new
    end
    # Now we iterate on the board(b) to add the initial
    # elements to the sets
    for rows in 0..8 do
      for cols in 0..8 do
        x = b[rows][cols] # curr cell value
        pos = ((rows / 3) * 3) + (cols / 3) # block # 0..8
        if x > 0 # It is not blank if true
          # add to the set(s)
          rs[rows] <<= x
          cs[cols] <<= x
          bs[pos] <<= x
        end
      end
    end
  end
  # Now.. this can be initial or a call > level1
  # search for the empties and compute a set diff
  # for what's wanted (1..9) and what we have.
  for rows in 0..8 do
    for cols in 0..8 do
      x = b[rows][cols]
      pos = ((rows / 3) * 3) + (cols / 3)
      if x == 0
        # The set diff at this row,col and pos
        s = $fs - (cs[cols] | rs[rows] | bs[pos])
        # distilled down to all possible 1..9's that can go here.
        choices[[rows,cols]] = s
      end
    end
  end
  l = choices.sort_by { |rc,s| s.size }
#  print "level:",level,"\n"
#  print_board(b)
#  print_set("rs", rs)
#  print_set("cs", cs)
#  print_set("bs", bs)
#  l.each do |x|
#    print x[0],"\n"
#    x[1].each { |y| puts y }
#  end

  if l.size == 0
    puts "\nSolution"
    print_board(b)
    exit
  end
  # move is encoded at l[0]
  m = l[0][0]
  r = m[0]
  c = m[1]
  pos = ((r / 3) * 3) + (c / 3)
  s = l[0][1]
  s.each do |x|
#    printf "Move[%d][%d] = %d\n", r,c,x
    b[r][c] = x
    if cs[c].include?(x)
      return
    else
      cs[c] <<= x
    end
    if rs[r].include?(x)
      return
    else
      rs[r] <<= x
    end
    if bs[pos].include?(x)
      return
    else
      bs[pos] <<= x
    end
    move(b,rs,cs,bs,level+1)
    # undo the move
    b[r][c] = 0
    cs[c].delete(x)
    rs[r].delete(x)
    bs[pos].delete(x)
  end
end

# code starts here. less arg check at the top.

board = Array.new

# read in the board
File.readlines(ARGV[0]).each do |line|
   line.chomp!   # get rid of the NL
   a = line.split("").map { |s| s.to_i }  # ea # is a numeric value in an array
   board.push(a)
end

puts "Input"
print_board(board)

move(board,nil,nil,nil,0)






