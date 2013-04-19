class Explosion
  def initialize(x, y, window)
    @origin         = [x, y]
    @window         = window
    @initialized_at = Time.now.to_f

    # How many bits to make
    @explodiness    = 20

    # The distance bits should travel
    @exploderation  = 40

    # How long should the effect last
    @how_long       = 0.75

    # Gosu::Color::RED, http://www.libgosu.org/rdoc/Gosu/Color.html
    @color          = Gosu::Color.argb(0xffff0000)

    # Precalculate all the angle vectors, these are around the circle origin [0,0]
    @directions     = @explodiness.times.collect do |i|
      angle = (i / @explodiness.to_f) * (Math::PI * 2)
      cos, sin = Math.cos(angle), Math.sin(angle)
      [sin , cos]
    end
  end

  def done?
    (Time.now.to_f - @initialized_at) > @how_long
  end

  def draw
    percentage_complete = (Time.now.to_f - @initialized_at) / @how_long.to_f

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
      dx *= magnitude*rand
      dy *= magnitude*rand

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
