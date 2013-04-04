require "bundler"
Bundler.require(:default)

puts "Starting up!"
class Sprite
  attr_accessor  :x, :y
  def initialize(x,y, window)
    @x=x
    @y=y
    @window =window
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
end

class Shot < Sprite
  def initialize(x,y, window)
    @images = [Gosu::Image.new(window, "shot.png" , true)]
    super
  end
  def update
    @y -=5
    if @y <=0
      @window.shots.delete(self)
    end
  end
end

class Player < Sprite
  attr_accessor :score

  def initialize(x,y, window)
    @images = [Gosu::Image.new(window, "ship.png" , true)]
    self.score = 0
    super
  end

  def update
    if @window.button_down? Gosu::KbLeft
      @x -= 3
    end
    if @window.button_down? Gosu::KbRight
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
    @images = [Gosu::Image.new(window, "red-ship.png", true), Gosu::Image.new(window, "red-ship-2.png", true)]
    self.point_value = 10
    super
  end


  def update
   # @x += Math.sin(Time.now.to_f * 6) * 4
   # @y += Math.cos(Time.now.to_f * 4) * 4
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
    @exploderation  = 45

    # How long should the effect last
    @how_long       = 1.25

    # Gosu::Color::RED, http://www.libgosu.org/rdoc/Gosu/Color.html
    @color          = Gosu::Color.argb(0xffff0000)

    # Precalculate all the angle vectors, these are around the circle origin [0,0]
    @directions     = @explodiness.times.collect do |i|
      angle = (i / @explodiness.to_f) * (Math::PI * 2)
      cos, sin = Math.cos(angle), Math.sin(angle)
      [cos - sin , sin  + cos]
    end
  end

  def done?(eval_at = Time.now)
    (eval_at.to_i - @initialized_at) > @how_long
  end

  def draw
    percentage_complete = ((Time.now.to_f - @initialized_at) / @how_long.to_f)

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
      dx *= magnitude
      dy *= magnitude

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






class Galaga < Gosu::Window
  attr_accessor :shots
  WIDTH  = 640
  HEIGHT = 480
  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = "Galaga"

    @shots = []
    @theme = Gosu::Sample.new(self, "Theme.mp3")
    @shot_sound = Gosu::Sample.new(self, "shot_sound.mp3")
    @kill_sound = Gosu::Sample.new(self, "kill.mp3")
    @player1 = Player.new(320, 480-19, self)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @theme.play
    @enemies =[]
    @explosions = []
    200.times do
      @enemies.push(Enemy.new(rand(width-12), rand(height-30) ,self))
    end
  end

  def update
    if button_down? Gosu::KbEscape
      close
    end

    @shots.each do |shot|
      shot.update
    end

    @enemies.each do |enemy|
      enemy.update
    end

    @shots.each do | shot |
      @enemies.each do |enemy|
        if (enemy.x1..enemy.x2).include?(shot.x)
          if (enemy.y1..enemy.y2).include?(shot.y)
            @explosions << Explosion.new(enemy.x1, enemy.y1, self)
            @enemies.delete(enemy)
            @shots.delete(shot)
            @kill_sound.play
            @player1.score += enemy.point_value
          end
        end
      end
    end

    @explosions.delete_if do |explosion|
      explosion.done?
    end

    @player1.update
  end

  def shoot
    @shots.push(Shot.new(@player1.x+9, 480-19, self))
    @shot_sound.play
  end

  def button_down(id)
    case id
    when Gosu::KbSpace
      if @shots.size <3
        shoot
      end
    end
  end

  def draw
    @font.draw("SCORE: #{@player1.score}", WIDTH/2, 10, 10, 1.0, 1.0, 0xffffff00)
    @shots.each do |shot|
      shot.draw
    end
    @enemies.each do |enemy|
      enemy.draw
    end
    @explosions.each do |boom|
      boom.draw
    end
    @player1.draw
  end
end

window = Galaga.new
window.show
