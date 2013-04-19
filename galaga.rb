require "bundler"
Bundler.require(:default)

class Sprite
  attr_accessor  :x, :y

  def initialize(x, y, window)
    @x      = x
    @y      = y
    @window = window
    @image_index = 0
  end

  def draw
    @image_index = Gosu::milliseconds / 350 % @images.size
    @image = @images[@image_index].draw(@x, @y, 0)
  end

  def update
  end

  def x1
    @x
  end

  def x2
    @x+ (@images[@image_index].width)
  end

  def y2
    @y
  end

  def y1
    @y - @images[@image_index].height
  end

  def hit?(other)
    if (other.x1..other.x2).include?(@x)
      if (other.y1..other.y2).include?(@y)
        return true
      end
    end
  end


end

class Shot < Sprite
  SHOTSPEED = 5

  def initialize(x, y, window)
    @images = [Gosu::Image.new(window, "images/shot.png" , true)]
    super
  end

  def update
    @y -= SHOTSPEED
    if @y <= -SHOTSPEED
      @window.shots.delete(self)
    end
  end
end

class EnemyShot < Sprite
  SHOTSPEED = -5

  def initialize(x, y, window)
    @images = [Gosu::Image.new(window, "images/enemyshot.png" , true)]
    super
  end

  def update
    @y -= SHOTSPEED
    if @y >= @window.height
      @window.enemyshots.delete(self)
    end
  end
end

class Player < Sprite
  attr_accessor :score, :alive

  def initialize(x, y, window)
    @images = [Gosu::Image.new(window, "images/ship.png" , true)]
    self.score = 0
    @alive = true
    super
  end

  def update
    if @window.button_down?(Gosu::KbLeft)
      @x -= 3
    end
    if @window.button_down?(Gosu::KbRight)
      @x += 3
    end

    if @x <=0
      @x = 0
    end

    if @x >= 640 - 19
      @x = 640-19
    end
  end

end

class Enemy < Sprite
  attr_accessor :point_value

  def initialize(x,y,window)
    @images = [Gosu::Image.new(window, "images/red-ship.png", true), Gosu::Image.new(window, "images/red-ship-2.png", true)]
    self.point_value = 10
    super
  end

  def update
   # @x += Math.sin(Time.now.to_f * 6) * 4
   # @y += Math.cos(Time.now.to_f * 4) * 4

   if Time.now.to_f - @lastshot.to_f > 2
    if @window.enemyshots.size <3
      @window.enemyshoot
      @lastshot = Time.now.to_f
    end
  end
end

end

class Explosion
  def initialize(x, y, window)
    @origin         = [x, y]
    @window         = window
    @initialized_at = Time.now.to_f

    # How many bits to make
    @explodiness    = 20

    # The distance bits should travel
    @exploderation  = 40

    # How long should the effect last
    @how_long       = 0.75

    # Gosu::Color::RED, http://www.libgosu.org/rdoc/Gosu/Color.html
    @color          = Gosu::Color.argb(0xffff0000)

    # Precalculate all the angle vectors, these are around the circle origin [0,0]
    @directions     = @explodiness.times.collect do |i|
      angle = (i / @explodiness.to_f) * (Math::PI * 2)
      cos, sin = Math.cos(angle), Math.sin(angle)
      [sin , cos]
    end
  end

  def done?
    (Time.now.to_f - @initialized_at) > @how_long
  end

  def draw
    percentage_complete = (Time.now.to_f - @initialized_at) / @how_long.to_f

    # The distance away from the original explosion point to draw each bit
    magnitude = percentage_complete * @exploderation

    # The amount to fade the effect color by, when the effect completes it should
    # be almost 0
    current_alpha = ((1.0 - percentage_complete) * 255).to_i
    @color.alpha = [current_alpha, 0].max

    @directions.each do |vector|
      # Start at origin
      dx, dy = vector

      # Move away by magnitude
      dx *= magnitude*rand
      dy *= magnitude*rand

      # Translate from explosion original position
      px, py = @origin[0] + dx, @origin[1] + dy

      # Draw a tiny 1 pixel box as the effect 'bit'
      @window.draw_quad(px, py, @color, # lower left
                        px, py + 1, @color,  # upper left
                        px + 1, py + 1, @color,  # upper right
                        px + 1, py, @color) # lower right
    end
  end
end

class StarField
  STARCOUNT = 32

  def initialize(window)
    @window         = window
    @initialized_at = Time.now.to_f
    @pxs            = []
    @pys            = []
    STARCOUNT.times do
      @pxs.push(rand(@window.width))
      @pys.push(rand(@window.height))
    end
  end

  def update
    STARCOUNT.times do |index|
      if index % 2 == 0
        @pys[index] +=1
      else
        @pys[index] += 0.5
      end
      if @pys[index] >= 480
        @pys[index] = 0
        @pxs[index] = rand(@window.width)
      end
    end
  end

  def draw
    STARCOUNT.times do |index|
      @color = Gosu::Color.argb(0xffffffff)
      if (@pxs[index] + 15 * Time.now.to_f) % 10 < 8
        @window.draw_pixel( @pxs[index], @pys[index], @color)
      end
    end
  end
end


class Galaga < Gosu::Window
  WIDTH  = 640
  HEIGHT = 480

  attr_accessor :shots, :enemyshots

  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = "Galaga"

    @starfield = StarField.new(self)
    @shots = []
    @enemyshots = []
    @theme = Gosu::Sample.new(self, "sounds/Theme.mp3")
    @shot_sound = Gosu::Sample.new(self, "sounds/shot_sound.mp3")
    @kill_sound = Gosu::Sample.new(self, "sounds/kill.mp3")
    @player1 = Player.new(WIDTH/2, HEIGHT-19, self)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @theme.play
    @enemies =[]
    @explosions = []
    200.times do
      @enemies.push(Enemy.new(rand(WIDTH-12), rand(HEIGHT-30), self))
    end
  end

  def update
    if button_down?(Gosu::KbEscape)
      close
    end

    @shots.each do |shot|
      shot.update
    end

    @enemyshots.each do |shot|
      shot.update
    end

    @enemies.each do |enemy|
      enemy.update
    end

    @starfield.update

    @shots.each do | shot |
      @enemies.each do |enemy|
        if shot.hit?(enemy)
          @explosions << Explosion.new(enemy.x1, enemy.y1, self)
          @enemies.delete(enemy)
          @shots.delete(shot)
          @kill_sound.play
          @player1.score += enemy.point_value
        end
      end
    end

    @enemyshots.each do | shot|
      if @player1.alive && shot.hit?(@player1)
        @explosions << Explosion.new(@player1.x1, @player1.y1, self)
        @player1.alive = false
        @enemyshots.delete(shot)
        @kill_sound.play
      end
    end

    @explosions.delete_if do |explosion|
      explosion.done?
    end
    if @player1.alive
      @player1.update
    end
  end

  def shoot
    @shots.push(Shot.new(@player1.x+9, 480-19, self))
    @shot_sound.play
  end

  def button_down(id)
    case id
    when Gosu::KbSpace
      if @shots.size <3 && @player1.alive
        shoot
      end
    end
  end

  def enemyshoot
    @enemyshooter = @enemies.sample
    @enemyshots.push(EnemyShot.new(@enemyshooter.x + 5, @enemyshooter.y, self))
    @shot_sound.play
  end



  def draw_pixel (px, py, color)
    draw_quad(px,     py,     color, # lower left
              px,     py + 1, color, # upper left
              px + 1, py + 1, color, # upper right
              px + 1, py,     color) # lower right
  end


  def draw
    @font.draw("SCORE: #{@player1.score}", WIDTH/2, 10, 10, 1.0, 1.0, 0xffffff00)
    @starfield.draw
    @enemyshots.each do |shot|
      shot.draw
    end
    @shots.each do |shot|
      shot.draw
    end
    @enemies.each do |enemy|
      enemy.draw
    end
    @explosions.each do |boom|
      boom.draw
    end
    if @player1.alive
      @player1.draw
    end
  end
end

puts "Starting up!"
window = Galaga.new
window.show
