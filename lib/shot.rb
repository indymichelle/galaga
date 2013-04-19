
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
