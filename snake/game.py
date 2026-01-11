import pygame
from snake.settings import WIDTH, HEIGHT, FPS, BLACK, WHITE, GRID
from snake.snake import Snake
from snake.food import Food


def _hit_wall(head):
    x, y = head
    return x < 0 or y < 0 or x >= WIDTH or y >= HEIGHT


def _hit_self(body):
    return body[0] in body[1:]


def run():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Snake Fun")
    clock = pygame.time.Clock()
    font = pygame.font.SysFont("monospace", 24)

    snake = Snake()
    food = Food()
    score = 0
    game_over = False

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                if game_over and event.key == pygame.K_r:
                    snake = Snake()
                    food = Food()
                    score = 0
                    game_over = False
                elif not game_over:
                    if event.key == pygame.K_UP:
                        snake.set_direction((0, -GRID))
                    elif event.key == pygame.K_DOWN:
                        snake.set_direction((0, GRID))
                    elif event.key == pygame.K_LEFT:
                        snake.set_direction((-GRID, 0))
                    elif event.key == pygame.K_RIGHT:
                        snake.set_direction((GRID, 0))

        if not game_over:
            snake.move()
            if snake.body[0] == food.position:
                snake.grow()
                food.respawn(snake.body)
                score += 10
            if _hit_wall(snake.body[0]) or _hit_self(snake.body):
                game_over = True

        screen.fill(BLACK)
        snake.draw(screen)
        food.draw(screen)
        score_text = font.render(f"Score: {score}", True, WHITE)
        screen.blit(score_text, (10, 10))
        if game_over:
            msg = font.render("GAME OVER - pressione R", True, WHITE)
            screen.blit(msg, (WIDTH // 2 - 160, HEIGHT // 2))
        pygame.display.flip()
        clock.tick(FPS)

    pygame.quit()
