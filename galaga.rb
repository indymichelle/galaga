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
    @image.draw(@x, @y,0)
  end
  def update
  end
end

class Shot < Sprite
  def initialize(x,y, window)
    @image = Gosu::Image.new(window, "shot.png" , true)
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
  def initialize(x,y, window)
    @image = Gosu::Image.new(window, "ship.png" , true)
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
  def initialize(x,y,window)
    @image = Gosu::Image.new(window, "red-ship.png", true)
    super
  end
end




class Galaga < Gosu::Window
  attr_accessor :shots
  def initialize
    super(640, 480, false)
    self.caption = "Galaga"

    @shots = []
    @theme = Gosu::Sample.new(self, "Theme.mp3")
    @shot_sound = Gosu::Sample.new(self, "shot_sound.mp3")
    @player1 = Player.new(320, 480-19, self)
    @enemy1 = Enemy.new(320, 320,self)
    @theme.play
  end

  def update
    if button_down? Gosu::KbEscape
      close
    end

    @shots.each do |shot|
      shot.update
    end

    @enemy1.update
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
    @shots.each do |shot|
      shot.draw
    end
    @enemy1.draw
    @player1.draw
  end
end

window = Galaga.new
window.show
