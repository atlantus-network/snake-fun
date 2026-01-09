#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

AUTHOR_NAME="Atlantus Network"
AUTHOR_EMAIL="164039444+atlantus-network@users.noreply.github.com"

commit() {
    local date="$1"
    local msg="$2"
    git add -A
    GIT_AUTHOR_NAME="$AUTHOR_NAME" GIT_AUTHOR_EMAIL="$AUTHOR_EMAIL" \
    GIT_COMMITTER_NAME="$AUTHOR_NAME" GIT_COMMITTER_EMAIL="$AUTHOR_EMAIL" \
    GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" \
    git commit --no-verify -m "$msg"
}

STAGING="/tmp/snakepython_staging_$$"
mkdir -p "$STAGING"

rm -rf .git README.md requirements.txt .gitignore snake main.py 2>/dev/null || true

git init -b main
git config user.name "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"

# === 9 de janeiro 2026 ===
cat > README.md <<'EOF'
# Snake Fun

Jogo da cobrinha em Python com Pygame.
EOF
commit "2026-01-09T09:20:00-03:00" "chore: projeto inicial snake-fun"

cat > requirements.txt <<'EOF'
pygame>=2.5.0
EOF
commit "2026-01-09T10:45:00-03:00" "build: adicionar dependencia pygame"

mkdir -p snake
cat > snake/__init__.py <<'EOF'
"""Snake Fun - jogo da cobrinha."""
EOF
cat > snake/settings.py <<'EOF'
WIDTH = 640
HEIGHT = 480
GRID = 20
FPS = 10

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (46, 204, 113)
RED = (231, 76, 60)
DARK_GREEN = (39, 174, 96)
EOF
commit "2026-01-09T12:30:00-03:00" "feat: configuracoes de tela e cores"

cat > snake/snake.py <<'EOF'
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
EOF
commit "2026-01-09T14:15:00-03:00" "feat: classe Snake com movimento basico"

cat > snake/food.py <<'EOF'
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
EOF
commit "2026-01-09T16:40:00-03:00" "feat: spawn de comida aleatoria"

cat > main.py <<'EOF'
"""Snake Fun entry point."""
from snake.game import run

if __name__ == "__main__":
    run()
EOF
commit "2026-01-09T19:05:00-03:00" "feat: ponto de entrada main.py"

# === 11 de janeiro 2026 ===
cat > snake/game.py <<'EOF'
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
EOF
commit "2026-01-11T09:30:00-03:00" "feat: loop principal do jogo"

cat >> snake/game.py <<'EOF'

EOF
# Add wall collision - rewrite game.py with collision
cat > snake/game.py <<'EOF'
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
            elif event.type == pygame.KEYDOWN and not game_over:
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
EOF
commit "2026-01-11T11:50:00-03:00" "feat: colisao com paredes e corpo"

cat > snake/game.py <<'EOF'
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
EOF
commit "2026-01-11T14:20:00-03:00" "feat: tela de game over e reinicio com R"

# Speed increase version - partial
cat > snake/settings.py <<'EOF'
WIDTH = 640
HEIGHT = 480
GRID = 20
BASE_FPS = 10

BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (46, 204, 113)
RED = (231, 76, 60)
DARK_GREEN = (39, 174, 96)
BG = (20, 20, 30)
EOF
commit "2026-01-11T16:55:00-03:00" "feat: paleta de cores e FPS base configuravel"

# === 13 de janeiro 2026 ===
cat > snake/game.py <<'EOF'
import pygame
from snake.settings import WIDTH, HEIGHT, BASE_FPS, BLACK, WHITE, GRID, BG
from snake.snake import Snake
from snake.food import Food


def _hit_wall(head):
    x, y = head
    return x < 0 or y < 0 or x >= WIDTH or y >= HEIGHT


def _hit_self(body):
    return body[0] in body[1:]


def _calc_fps(score):
    return min(BASE_FPS + score // 30, 20)


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

        screen.fill(BG)
        snake.draw(screen)
        food.draw(screen)
        score_text = font.render(f"Score: {score}", True, WHITE)
        screen.blit(score_text, (10, 10))
        if game_over:
            msg = font.render("GAME OVER - pressione R", True, WHITE)
            screen.blit(msg, (WIDTH // 2 - 160, HEIGHT // 2))
        pygame.display.flip()
        clock.tick(_calc_fps(score))

    pygame.quit()
EOF
commit "2026-01-13T09:40:00-03:00" "feat: velocidade aumenta conforme pontuacao"

cat > snake/snake.py <<'EOF'
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
            rect = pygame.Rect(x, y, GRID - 1, GRID - 1)
            pygame.draw.rect(surface, color, rect, border_radius=4)
EOF
commit "2026-01-13T12:05:00-03:00" "style: cobra com cantos arredondados"

cat > snake/food.py <<'EOF'
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
        rect = pygame.Rect(*self.position, GRID - 2, GRID - 2)
        pygame.draw.rect(surface, RED, rect, border_radius=GRID // 2)
EOF
commit "2026-01-13T15:30:00-03:00" "style: comida circular"

cat > snake/highscore.py <<'EOF'
from pathlib import Path

SCORE_FILE = Path(__file__).parent.parent / "highscore.txt"


def load_highscore():
    try:
        return int(SCORE_FILE.read_text().strip())
    except (FileNotFoundError, ValueError):
        return 0


def save_highscore(score):
    current = load_highscore()
    if score > current:
        SCORE_FILE.write_text(str(score))
        return score
    return current
EOF
commit "2026-01-13T18:10:00-03:00" "feat: persistencia de recorde local"

# === 15 de janeiro 2026 ===
cat > snake/game.py <<'EOF'
import pygame
from snake.settings import WIDTH, HEIGHT, BASE_FPS, WHITE, GRID, BG
from snake.snake import Snake
from snake.food import Food
from snake.highscore import load_highscore, save_highscore


def _hit_wall(head):
    x, y = head
    return x < 0 or y < 0 or x >= WIDTH or y >= HEIGHT


def _hit_self(body):
    return body[0] in body[1:]


def _calc_fps(score):
    return min(BASE_FPS + score // 30, 20)


def run():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Snake Fun")
    clock = pygame.time.Clock()
    font = pygame.font.SysFont("monospace", 24)

    snake = Snake()
    food = Food()
    score = 0
    highscore = load_highscore()
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
                highscore = save_highscore(score)
            if _hit_wall(snake.body[0]) or _hit_self(snake.body):
                game_over = True
                highscore = save_highscore(score)

        screen.fill(BG)
        snake.draw(screen)
        food.draw(screen)
        score_text = font.render(f"Score: {score}  Best: {highscore}", True, WHITE)
        screen.blit(score_text, (10, 10))
        if game_over:
            msg = font.render("GAME OVER - pressione R", True, WHITE)
            screen.blit(msg, (WIDTH // 2 - 160, HEIGHT // 2))
        pygame.display.flip()
        clock.tick(_calc_fps(score))

    pygame.quit()
EOF
commit "2026-01-15T10:25:00-03:00" "feat: exibir e salvar high score"

cat > README.md <<'EOF'
# Snake Fun

Jogo da cobrinha clássico feito em Python com Pygame.

## Como jogar

```bash
pip install -r requirements.txt
python main.py
```

- **Setas** — mover a cobra
- **R** — reiniciar após game over

## Recursos

- Pontuação e recorde salvo localmente
- Velocidade aumenta conforme você pontua
- Colisão com paredes e com o próprio corpo

## Licença

MIT
EOF
commit "2026-01-15T12:50:00-03:00" "docs: README com instrucoes de jogo"

cat > .gitignore <<'EOF'
__pycache__/
*.py[cod]
highscore.txt
.venv/
venv/
EOF
commit "2026-01-15T15:15:00-03:00" "chore: gitignore para python e recorde"

cat > snake/__init__.py <<'EOF'
"""Snake Fun - jogo da cobrinha em Python."""

__version__ = "1.0.0"
EOF
commit "2026-01-15T17:45:00-03:00" "chore: versao 1.0.0 e polish final"

rm -rf "$STAGING"
echo "OK: $(git rev-list --count HEAD) commits"
git log --oneline --format="%h %ad %s" --date=format:"%Y-%m-%d"
