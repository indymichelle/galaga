require "bundler"
Bundler.require(:default)


puts "Starting up!"

class Galaga < Gosu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Galaga"

    @shot_sound = Gosu::Sample.new(self, "shot_sound.mp3")
    @ship_image = Gosu::Image.new(self, "ship.png" , true)
    @shot_image = Gosu::Image.new(self, "shot.png" , true)
    @player_x = 320
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
    if button_down? Gosu::KbSpace
      if @shot_x == nil
        shoot
      end
    end
    if @shot_x
      @shot_y -=5  
      if @shot_y <= 0
        @shot_x = nil
      end
    end
  end
  
  def shoot
    @shot_x = @player_x+8
    @shot_y = 480-19
    @shot_sound.play 
  end

  def draw
    @ship_image.draw(@player_x,480-19,0)
    if @shot_x
      @shot_image.draw(@shot_x, @shot_y,0) #shot image
    end
  end
end

window = Galaga.new
window.show

