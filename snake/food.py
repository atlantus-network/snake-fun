import random
import pygame
from snake.settings import GRID, WIDTH, HEIGHT, RED


class Food:
    def __init__(self):
        self.position = (0, 0)
        self.respawn([])

    def respawn(self, snake_body):
        while True:
            x = random.randrange(0, WIDTH, GRID)
            y = random.randrange(0, HEIGHT, GRID)
            if (x, y) not in snake_body:
                self.position = (x, y)
                break

    def draw(self, surface):
        rect = pygame.Rect(*self.position, GRID, GRID)
        pygame.draw.rect(surface, RED, rect)
