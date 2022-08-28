require 'ruby2d'


set background:'navy' #background-color
set fps_cap: 25 #frames_per_second

GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT =  Window.height / GRID_SIZE

class Snake

    attr_writer :direction

#inicialização e construção da cobra

    def initialize
        @positions = [ [2, 0], [2, 1], [2, 2], [2, 3] ]
        @direction = 'down'
        @growing = false
        @finished = false
    end

    def draw
        @positions.each do |position|
          Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, size: GRID_SIZE - 1, color: '#eebbc3')
        end
    end
        


#movimentação da cobra de acordo com o event.key(teclado)

    def move
      if !@growing
        @positions.shift
      end
      case @direction
      when 'down'
        @positions.push( new_coords( head[0], head[1] + 1 ))  
      when 'up'
        @positions.push( new_coords( head[0], head[1] - 1 ))
      when 'left'
        @positions.push( new_coords( head[0] - 1, head[1]  ))
      when 'right'
        @positions.push( new_coords(  head[0] + 1, head[1]  ))
      end
      @growing = false
    end

    def can_change_direction_to?(new_direction)
        case @direction
        when 'up' then new_direction != 'down'
        when 'down' then new_direction != 'up'
        when 'left' then new_direction != 'right'
        when 'right' then new_direction != 'left'
        end
    end

    def x
      head[0]
    end

    def y
      head[1]
    end

    def grow
      @growing = true      
    end

    def hit_itself?
      @positions.uniq.length != @positions.length
    end


    private 

#faz com que a cobra consiga transitar pelas laterais da tela
#quando a largura for digamos, 41 e o máximo for 40, ao achar o mod
#o resultado será 1, fazendo ela voltar ao inicio
    def new_coords(x, y)
        [x % GRID_WIDTH, y % GRID_HEIGHT]
    end

    def head
      @positions.last
    end
end


class Game
  def initialize
    @score = 0
    @food_x = rand(GRID_WIDTH)
    @food_y = rand(GRID_HEIGHT)
  end

  def draw
    unless finished?
      Square.new(x: @food_x * GRID_SIZE, y: @food_y * GRID_SIZE, size: GRID_SIZE, color: 'red')
    end
      Text.new(text_message, color: "white", x:15, y:15, size:15)
  end

  def snake_hit_ball?(x, y)
    @food_x == x && @food_y == y
  end

  #torna randomico o spawn da comida/bolinha/quadrado
  def randomize
    @food_x = rand(GRID_WIDTH)
    @food_y = rand(GRID_HEIGHT)
  end

  def record_hit
    @score += 1
    randomize
  end

  def finish
    @finished = true
  end

  def finished?
    @finished
  end

  private

  def text_message
    if finished?
      "Game over, your score was: #{@score}. Press R to restart"
      else
      "Score: #{@score}"
    end
  end

end

snake = Snake.new
game = Game.new

#a cada frame faça isto:

update do
    clear

  unless game.finished?
    snake.move
  end
    snake.draw
    game.draw

    if game.snake_hit_ball?(snake.x, snake.y)
      game.record_hit
      snake.grow
    end

    if snake.hit_itself?
      game.finish
    end

end

#passa a direção conforme o evento de clique do teclado acontece, porém
# com uma verificação antes

on :key_down do |event|
    if ['up', 'down', 'left', 'right'].include?(event.key)
        if snake.can_change_direction_to?(event.key)
            snake.direction = event.key
        end
      else if event.key == 'r'
        snake = Snake.new
        game = Game.new
      end
    end
end

show
