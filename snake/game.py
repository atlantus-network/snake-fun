import pygame
from snake.settings import WIDTH, HEIGHT, FPS, BLACK, WHITE
from snake.snake import Snake
from snake.food import Food


def run():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Snake Fun")
    clock = pygame.time.Clock()
    font = pygame.font.SysFont("monospace", 24)

    snake = Snake()
    food = Food()

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_UP:
                    snake.set_direction((0, -20))
                elif event.key == pygame.K_DOWN:
                    snake.set_direction((0, 20))
                elif event.key == pygame.K_LEFT:
                    snake.set_direction((-20, 0))
                elif event.key == pygame.K_RIGHT:
                    snake.set_direction((20, 0))

        snake.move()
        if snake.body[0] == food.position:
            snake.grow()
            food.respawn(snake.body)

        screen.fill(BLACK)
        snake.draw(screen)
        food.draw(screen)
        score_text = font.render(f"Score: {len(snake.body) - 3}", True, WHITE)
        screen.blit(score_text, (10, 10))
        pygame.display.flip()
        clock.tick(FPS)

    pygame.quit()
