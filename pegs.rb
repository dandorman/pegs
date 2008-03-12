class Integer
  def triangle?
    triangle_number = 1
    row = 1
    while triangle_number < self
      row += 1
      triangle_number += row
    end
    if triangle_number == self
      true
    else
      false
    end
  end

  def triangle_row
    triangle_number = 1
    row = 1
    while triangle_number < self
      row += 1
      triangle_number += row
    end
    row
  end

  def prev_triangle
    triangle_number = 1
    row = 1
    prev_triangle_number = nil
    until triangle_number >= self do
      prev_triangle_number = triangle_number
      row += 1
      triangle_number += row
    end
    prev_triangle_number
  end

  def next_triangle
    triangle_number = 1
    row = 1
    while triangle_number <= self do
      row += 1
      triangle_number += row
    end
    triangle_number
  end

  def upper_right
    if self.triangle?
      upper_right = nil
    else
      offset = self.next_triangle - self - 1
      upper_right = self.prev_triangle - offset
    end
    upper_right
  end

  def right
    if self.triangle?
      right = nil
    else
      right = self + 1
    end
    right
  end

  def lower_right
    if self.triangle?
      lower_right = self.next_triangle
    else
      offset = self - self.prev_triangle
      lower_right = self.next_triangle + offset + 1
    end
    lower_right
  end

  def lower_left
    if self.triangle?
      lower_left = self + self.triangle_row
    else
      offset = self - self.prev_triangle
      lower_left = self.next_triangle + offset
    end
    lower_left
  end

  def left
    if (self - 1).triangle? or self - 1 < 1
      left = nil
    else
      left = self - 1
    end
    left
  end

  def upper_left
    if self - 1 < 1 or (self - 1).triangle?
      upper_left = nil
    else
      if self.triangle?
        offset = 0
      else
        offset = self.next_triangle - self
      end
      upper_left = self.prev_triangle - offset
    end
    upper_left
  end
end

class Jump
  attr_accessor :starting_hole, :jumped_hole, :landing_hole

  def initialize(starting, jumped, landing)
    @starting_hole = starting
    @jumped_hole = jumped
    @landing_hole = landing
  end

  def to_s
    "[#{ @starting_hole }, #{ @jumped_hole }, #{ @landing_hole }]"
  end
end

class Hole
  def initialize(position)
    raise ArgumentError, "Position must be a positive integer" unless position > 0

    @holds_peg = false

    @position = position
  end

  def upper_right_jump
    if @upper_right_jump.nil?
      jumped_hole = @position.upper_right
      landing_hole = jumped_hole.upper_right unless jumped_hole.nil?
      @upper_right_jump = Jump.new @position, jumped_hole, landing_hole unless jumped_hole.nil? or landing_hole.nil?
    end
    @upper_right_jump
  end

  def right_jump
    if @right_jump.nil?
      jumped_hole = @position.right
      landing_hole = jumped_hole.right unless jumped_hole.nil?
      @right_jump = Jump.new @position, jumped_hole, landing_hole unless jumped_hole.nil? or landing_hole.nil?
    end
    @right_jump
  end

  def lower_right_jump
    if @lower_right_jump.nil?
      jumped_hole = @position.lower_right
      landing_hole = jumped_hole.lower_right unless jumped_hole.nil?
      @lower_right_jump = Jump.new @position, jumped_hole, landing_hole unless jumped_hole.nil? or landing_hole.nil?
    end
    @lower_right_jump
  end

  def lower_left_jump
    if @lower_left_jump.nil?
      jumped_hole = @position.lower_left
      landing_hole = jumped_hole.lower_left unless jumped_hole.nil?
      @lower_left_jump = Jump.new @position, jumped_hole, landing_hole unless jumped_hole.nil? or landing_hole.nil?
    end
    @lower_left_jump
  end

  def left_jump
    if @left_jump.nil?
      jumped_hole = @position.left
      landing_hole = jumped_hole.left unless jumped_hole.nil?
      @left_jump = Jump.new @position, jumped_hole, landing_hole unless jumped_hole.nil? or landing_hole.nil?
    end
    @left_jump
  end

  def upper_left_jump
    if @upper_left_jump.nil?
      jumped_hole = @position.upper_left
      landing_hole = jumped_hole.upper_left unless jumped_hole.nil?
      @upper_left_jump = Jump.new @position, jumped_hole, landing_hole unless jumped_hole.nil? or landing_hole.nil?
    end
    @upper_left_jump
  end

  attr_accessor :holds_peg
end

class PegBoard
  def initialize( size = 15 )
    raise ArgumentError, "Number must be a triangle number" unless size.triangle?
    @size = size
    @score = @size - 1
    @rows = @size.triangle_row
    @holes = []
    (1..@size).each do |position|
      @holes[position] = Hole.new position
      @holes[position].holds_peg = true unless position == 1
    end
    @jumps = []
  end

  def copy
    board = PegBoard.new(@size)
    (1..@size).each do |position|
      board.holes[position] = Hole.new position
      board.holes[position].holds_peg = @holes[position].holds_peg
    end
    board
  end

  def draw
    leading_spaces = @rows - 1
    print " " * leading_spaces
    leading_spaces -= 1
    (1..@size).each do |position|
      if @holes[position].holds_peg
        print '*'
      else
        print '.'
      end
      if position.triangle?
        print "\n"
        print " " * leading_spaces unless position == @size
        leading_spaces -= 1
      else
        print ' '
      end
    end
  end

  def valid_jump( jump )
    valid = true
    if jump.nil?
      valid = false
    elsif jump.jumped_hole > @size or jump.landing_hole > @size
      valid = false
    else
      valid = false if !@holes[jump.starting_hole].holds_peg or !@holes[jump.jumped_hole].holds_peg or @holes[jump.landing_hole].holds_peg
    end
    valid
  end

  def available_jumps
    jumps = []
    (1..@size).each do |position|
      jumps.push @holes[position].upper_right_jump unless !valid_jump(@holes[position].upper_right_jump)
      jumps.push @holes[position].right_jump unless !valid_jump(@holes[position].right_jump)
      jumps.push @holes[position].lower_right_jump unless !valid_jump(@holes[position].lower_right_jump)
      jumps.push @holes[position].lower_left_jump unless !valid_jump(@holes[position].lower_left_jump)
      jumps.push @holes[position].left_jump unless !valid_jump(@holes[position].left_jump)
      jumps.push @holes[position].upper_left_jump unless !valid_jump(@holes[position].upper_left_jump)
    end
    jumps
  end

  def do_jump( jump )
    @holes[jump.starting_hole].holds_peg = false;
    @holes[jump.jumped_hole].holds_peg = false;
    @holes[jump.landing_hole].holds_peg = true;
    @score -= 1
    @jumps.push jump
  end

  def undo_jump
    if !@jumps.empty?
      jump = @jumps.pop
      @holes[jump.starting_hole].holds_peg = true;
      @holes[jump.jumped_hole].holds_peg = true;
      @holes[jump.landing_hole].holds_peg = false;
      @score += 1
    end
  end

  attr_reader :holes, :score
end

board = PegBoard.new 15

def get_jump_list(board)
  jumps = board.available_jumps
  if jumps.empty?
    nil
  else
    best_jumps = []
    jumps.each do |jump|
      board.do_jump jump
      next_jumps = get_jump_list board
      if next_jumps.nil?
        next_jumps = [jump]
      else
        next_jumps.unshift jump
      end
      best_jumps = next_jumps if !next_jumps.nil? and next_jumps.length > best_jumps.length
      board.undo_jump
    end
    best_jumps
  end
end

jump_list = get_jump_list board

board.draw
jump_list.each do |jump|
  puts jump
  board.do_jump jump
  board.draw
end
