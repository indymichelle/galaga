require "bundler"
Bundler.require(:default)


puts "Starting up!"
class Shot
  attr_accessor  :x, :y
  def initialize(x,y)
    @x=x
    @y=y
  end
end

class Galaga < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Galaga"
    
    @shots = []
    @theme = Gosu::Sample.new(self, "Theme.mp3")
    @shot_sound = Gosu::Sample.new(self, "shot_sound.mp3")
    @ship_image = Gosu::Image.new(self, "ship.png" , true)
    @shot_image = Gosu::Image.new(self, "shot.png" , true)
    @player_x = 320
    @theme.play
  end
  
  def update
    if button_down? Gosu::KbEscape
      close
    end

    if button_down? Gosu::KbLeft
      @player_x -= 3
    end
    if button_down? Gosu::KbRight
      @player_x += 3
    end
    
    if @player_x <=0
      @player_x = 0
    end

    if @player_x >= 640 - 19
      @player_x = 640-19
    end
    
    @shots.each do |shot|
      shot.y -=5  
      if shot.y <=0
        @shots.delete(shot)
      end
    end

  end
  
  def shoot
    @shots.push(Shot.new(@player_x+9, 480-19))
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
    @ship_image.draw(@player_x,480-19,0)
    @shots.each do |shot|
      @shot_image.draw(shot.x, shot.y,0) #shot image
    end 
  end
end

window = Galaga.new
window.show

