from turtle import Turtle

STARTING_POSITIONS = [(0, 0), (-20, 0), (-40, 0)]
MOVE_DISTANCE = 20
UP = 90
DOWN = 270
LEFT = 180
RIGHT = 0


class Snake(Turtle):
    def __init__(self):
        super().__init__()
        self.segments = []
        self.create_snake()
        self.head = self.segments[0]

    def create_snake(self):
        for position in STARTING_POSITIONS:
            self.add_segment(position)

    def add_segment(self, position):
        new_segment = Turtle("square")
        new_segment.color("white")
        new_segment.penup()
        new_segment.goto(position)
        self.segments.append(new_segment)

    def reset(self):
        for seg in self.segments:
            seg.goto(1000, 1000)
        self.segments.clear()
        self.create_snake()
        self.head = self.segments[0]

    def extend(self):
        # add a new segment to the snake
        self.add_segment(self.segments[-1].position())

    def move(self):
        for seg_num in range(len(self.segments) - 1, 0, -1):
            new_x = self.segments[seg_num - 1].xcor()
            new_y = self.segments[seg_num - 1].ycor()
            self.segments[seg_num].goto(new_x, new_y)
        self.head.forward(MOVE_DISTANCE)

    def isUp(self):
        return self.head.heading() == UP

    def isDown(self):
        return self.head.heading() == DOWN

    def isLeft(self):
        return self.head.heading() == LEFT

    def isRight(self):
        return self.head.heading() == RIGHT

    def isWallHit(self):
        return (
            self.head.xcor() > 280
            or self.head.xcor() < -280
            or self.head.ycor() > 280
            or self.head.ycor() < -280
        )

    def isTailHit(self):
        was_hit = False
        for segment in self.segments[1:]:
            if self.head.distance(segment) < 10:
                was_hit = True
                break
        return was_hit

    def up(self):
        if not self.isDown():
            self.head.setheading(UP)

    def down(self):
        if not self.isUp():
            self.head.setheading(DOWN)

    def left(self):
        if not self.isRight():
            self.head.setheading(LEFT)

    def right(self):
        if not self.isLeft():
            self.head.setheading(RIGHT)
