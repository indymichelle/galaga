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
