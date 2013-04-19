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
