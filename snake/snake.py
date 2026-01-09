import pygame
from snake.settings import GRID


class Snake:
    def __init__(self):
        self.body = [(100, 100), (80, 100), (60, 100)]
        self.direction = (GRID, 0)

    def move(self):
        head_x, head_y = self.body[0]
        dx, dy = self.direction
        self.body.insert(0, (head_x + dx, head_y + dy))
        self.body.pop()

    def grow(self):
        tail = self.body[-1]
        self.body.append(tail)

    def set_direction(self, direction):
        dx, dy = direction
        cur_dx, cur_dy = self.direction
        if (dx, dy) != (-cur_dx, -cur_dy):
            self.direction = direction

    def draw(self, surface):
        from snake.settings import GREEN, DARK_GREEN
        for i, (x, y) in enumerate(self.body):
            color = DARK_GREEN if i == 0 else GREEN
            rect = pygame.Rect(x, y, GRID, GRID)
            pygame.draw.rect(surface, color, rect)
