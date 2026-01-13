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
