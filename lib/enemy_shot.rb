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
