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
