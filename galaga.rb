require "bundler"
Bundler.require(:default)
$: << "lib"

require "sprite"
require "shot"
require "enemy_shot"
require "enemy"
require "player"
require "explosion"
require "starfield"


class Galaga < Gosu::Window
  WIDTH  = 640
  HEIGHT = 480

  attr_accessor :shots, :enemyshots

  def initialize
    super(WIDTH, HEIGHT, false)
    self.caption = "Galaga"

    @starfield = StarField.new(self)
    @shots = []
    @enemyshots = []
    @theme = Gosu::Sample.new(self, "sounds/Theme.mp3")
    @shot_sound = Gosu::Sample.new(self, "sounds/shot_sound.mp3")
    @kill_sound = Gosu::Sample.new(self, "sounds/kill.mp3")
    @player1 = Player.new(WIDTH/2, HEIGHT-19, self)
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @theme.play
    @enemies =[]
    @explosions = []
    margin = 40
    rightside = WIDTH - margin - 16
    @enemy_grid_width = 20
    @enemy_grid_height = 5
    @enemy_grid_width.times do |index_x|
      x = index_x*(rightside - margin)/(@enemy_grid_width-1)+margin
      @enemy_grid_height.times do |index_y|
        y = index_y*margin + margin
        @enemies.push(Enemy.new(x, y, self))
      end
    end
  end

  def update
    if button_down?(Gosu::KbEscape)
      close
    end

    @shots.each do |shot|
      shot.update
    end

    @enemyshots.each do |shot|
      shot.update
    end

    @enemies.each do |enemy|
      enemy.update
    end

    @starfield.update

    @shots.each do | shot |
      @enemies.each do |enemy|
        if shot.hit?(enemy)
          @explosions << Explosion.new(enemy.x1, enemy.y1, self)
          @enemies.delete(enemy)
          @shots.delete(shot)
          @kill_sound.play
          @player1.score += enemy.point_value
        end
      end
    end

    @enemyshots.each do | shot|
      if @player1.alive && shot.hit?(@player1)
        @explosions << Explosion.new(@player1.x1, @player1.y1, self)
        @player1.alive = false
        @enemyshots.delete(shot)
        @kill_sound.play
      end
    end

    @explosions.delete_if do |explosion|
      explosion.done?
    end
    if @player1.alive
      @player1.update
    end
  end

  def shoot
    @shots.push(Shot.new(@player1.x+9, 480-19, self))
    @shot_sound.play
  end

  def button_down(id)
    case id
    when Gosu::KbSpace
      if @shots.size <3 && @player1.alive
        shoot
      end
    end
  end

  def enemyshoot
    @enemyshooter = @enemies.sample
    @enemyshots.push(EnemyShot.new(@enemyshooter.x + 5, @enemyshooter.y, self))
    @shot_sound.play
  end



  def draw_pixel (px, py, color)
    draw_quad(px,     py,     color, # lower left
              px,     py + 1, color, # upper left
              px + 1, py + 1, color, # upper right
              px + 1, py,     color) # lower right
  end


  def draw
    @font.draw("SCORE: #{@player1.score}", WIDTH/2, 10, 10, 1.0, 1.0, 0xffffff00)
    @starfield.draw
    @enemyshots.each do |shot|
      shot.draw
    end
    @shots.each do |shot|
      shot.draw
    end
    @enemies.each do |enemy|
      enemy.draw
    end
    @explosions.each do |boom|
      boom.draw
    end
    if @player1.alive
      @player1.draw
    end
  end
end

puts "Starting up!"
window = Galaga.new
window.show
