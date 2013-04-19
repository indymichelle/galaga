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
