final int WHITE = 0;
final int PURPLE = 1;
final int YELLOW = 2;
final int BLUE = 3;
final int ORANGE = 4;
final int RED = 5;
final int GREEN = 6;

int sketchWidth = 1024;
int sketchHeight = 1280;

int mx;
int my;

PImage bg;
PImage guide;
PImage[] gemImgs = new PImage[7];

Gem board[][] = new Gem[8][7];

int level = 1;
int score = 0;
int scoreNeeded = 10000;
int multiplier = 1;
int moves = 20;
int bestGem = int(random(3, 7));
do
	int worstGem = int(random(3, 7));
while (worstGem == bestGem);

void setup() {
	bg = loadImage("img/background.svg");
	guide = loadImage("img/guide.svg");
	gemImgs[0] = loadImage("img/gem0.svg");
	gemImgs[1] = loadImage("img/gem1.svg");
	gemImgs[2] = loadImage("img/gem2.svg");
	gemImgs[3] = loadImage("img/gem3.svg");
	gemImgs[4] = loadImage("img/gem4.svg");
	gemImgs[5] = loadImage("img/gem5.svg");
	gemImgs[6] = loadImage("img/gem6.svg");

	PFont font;
	font = loadFont("FFScala.ttf");
	textSize(48);

	for (int i = 0; i < 8; i++)
		for (int j = 0; j < 7; j++)
			board[i][j] = new Gem(i*128, j*128, board);

	checkMatches();
	score = 0;
	multiplier = 1;
	moves = 20;
	bestGem = int(random(3, 7));
	do
		worstGem = int(random(3, 7));
	while (worstGem == bestGem);
}

void draw() {
	mx = sketchWidth / width * mouseX;
	my = sketchHeight / height * mouseY;

	background(0);
	set(0, 0, bg);

	for (int i = 0; i < 8; i++)
		for (int j = 0; j < 7; j++) {
			board[i][j].update();
			board[i][j].display();
		}

	fill(0);
	rect(0, 896, 1024, 384);
	fill(255);
	text("Score: " + score + "/" + scoreNeeded, 50, 1000);
	text("Multiplier: " + multiplier, 50, 1100);
	text("Moves: " + moves, 50, 1050);
	text("Level: " + level, 50, 1150);
	switch(bestGem) {
		case 0: text("Best gem: white", sketchWidth / 2, 1000); break;
		case 1: text("Best gem: purple", sketchWidth / 2, 1000); break;
		case 2: text("Best gem: yellow", sketchWidth / 2, 1000); break;
		case 3: text("Best gem: blue", sketchWidth / 2, 1000); break;
		case 4: text("Best gem: orange", sketchWidth / 2, 1000); break;
		case 5: text("Best gem: red", sketchWidth / 2, 1000); break;
		case 6: text("Best gem: green", sketchWidth / 2, 1000); break;
	}
	switch(worstGem) {
		case 0: text("Worst gem: white", sketchWidth / 2, 1050); break;
		case 1: text("Worst gem: purple", sketchWidth / 2, 1050); break;
		case 2: text("Worst gem: yellow", sketchWidth / 2, 1050); break;
		case 3: text("Worst gem: blue", sketchWidth / 2, 1050); break;
		case 4: text("Worst gem: orange", sketchWidth / 2, 1050); break;
		case 5: text("Worst gem: red", sketchWidth / 2, 1050); break;
		case 6: text("Worst gem: green", sketchWidth / 2, 1050); break;
	}
}

void mouseReleased() {
	for (int i = 0; i < 8; i++)
		for (int j = 0; j < 7; j++) {
			board[i][j].othersHeld = false;
			if (board[i][j].held) {
				board[i][j].held = false;

				board[i][j].x = board[i][j].sx;
				board[i][j].y = board[i][j].sy;
				if (int(mx / 128) * 128 == board[i][j].sx || int(my / 128) * 128 == board[i][j].sy) {
					int[][] tempBoard = new int[8][7];
					for (int l = 0; l < 8; l++)
						for (int m = 0; m < 7; m++)
							tempBoard[l][m] = board[l][m].gem;

					int tempGem = board[i][j].gem;

					if (int(mx / 128) * 128 > board[i][j].sx)
						for (int k = i; k < int(mx / 128); k++)
							board[k][j].gem = board[k+1][j].gem;

					else if (int(mx / 128) * 128 < board[i][j].sx)
						for (int k = i; k > int(mx / 128); k--)
							board[k][j].gem = board[k-1][j].gem;

					else if (int(my / 128) * 128 > board[i][j].sy)
						for (int k = j; k < int(my / 128); k++)
							board[i][k].gem = board[i][k+1].gem;

					else
						for (int k = j; k > int(my / 128); k--)
							board[i][k].gem = board[i][k-1].gem;

					board[int(mx / 128)][int(my / 128)].gem = tempGem;

					if (!checkMatches()) {
						for (l = 0; l < 8; l++)
							for (m = 0; m < 7; m++)
								board[l][m].gem = tempBoard[l][m];
					} else {
						moves--;
						if (moves == 0) {
							level = 1;
							scoreNeeded = 10000
							println("Out of moves!");
							setup();
						}
					}

					if (score >= scoreNeeded) {
						level++;
						scoreNeeded += 2500;
						println("You win!");
						setup();
					}
				}
			}
		}
}

class Gem {
	int x, y, sx, sy;
	int w = 128;
	int h = 128;
	int gem = int(random(0, 7));
	boolean held = false;
	boolean othersHeld = false;
	Gem[][] others;

	Gem(int ix, int iy, Gem[][] o) {
		x = ix;
		y = iy;
		sx = ix;
		sy = iy;
		others = o;
	}

	void update() {
		for (int i = 0; i < 8; i++)
			for (int j = 0; j < 7; j++) {
				if (others[i][j].held)
					othersHeld = true;
			}

		if (!othersHeld && overRect(x, y, w, h) && mousePressed)
			held = true;

		if (held) {
			x = mx - w/2;
			y = my - h/2;
		}
	}

	void display() {
		if (held)
			set(sx-896, sy-768, guide);
		image(gemImgs[gem], x, y, w, h);
	}
}

boolean overRect(int x, int y, int w, int h) {
	return (mx >= x && mx <= x+w && my >= y && my <= y+h);
}

boolean checkMatches() {
	boolean match = false;

	for (int i = 0; i < 8; i++)
		for (int j = 0; j < 7; j++) {
			if (i < 6) if (board[i+1][j].gem == board[i][j].gem && board[i+2][j].gem == board[i][j].gem) {
				if (i < 5) if (board[i+3][j].gem == board[i][j].gem) {
					if (i < 4) if (board[i+4][j].gem == board[i][j].gem) {
						doMatch(board[i][j].gem);
						board[i+4][j].gem = -1;
					}
					doMatch(board[i][j].gem);
					board[i+3][j].gem = -1;
				}
				doMatch(board[i][j].gem);
				board[i][j].gem = -1;
				board[i+1][j].gem = -1;
				board[i+2][j].gem = -1;
				match = true;
			}
			if (j < 5) if (board[i][j+1].gem == board[i][j].gem && board[i][j+2].gem == board[i][j].gem) {
				if (j < 4) if (board[i][j+3].gem == board[i][j].gem) {
					if (j < 3) if (board[i][j+4].gem == board[i][j].gem) {
						doMatch(board[i][j].gem);
						board[i][j+4].gem = -1;
					}
					doMatch(board[i][j].gem);
					board[i][j+3].gem = -1;
				}
				doMatch(board[i][j].gem);
				board[i][j].gem = -1;
				board[i][j+1].gem = -1;
				board[i][j+2].gem = -1;
				match = true;
			}
		}

	for (int i = 0; i < 8; i++)
		for (int j = 0; j < 7; j++)
			if (board[i][j].gem == -1) {
				for (int k = j; k > 0; k--)
					board[i][k].gem = board[i][k-1].gem;
				board[i][0].gem = int(random(0, 7));
				checkMatches();
			}

	return(match);
}

void doMatch(int color) {
	if (color == PURPLE)
		score -= 500;
	else if (color == YELLOW)
		moves += 2;
	else if (color == WHITE)
		multiplier += 0.25;
	else if (color == bestGem)
		score += 200 * multiplier;
	else if (color == worstGem)
		score += 50 * multiplier;
	else
		score += 100 * multiplier;
	score = int(score);
}
