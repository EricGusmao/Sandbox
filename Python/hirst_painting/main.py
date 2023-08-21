import random as rd
import turtle as t

color_list = [
    (199, 175, 117),
    (124, 36, 24),
    (168, 106, 57),
    (186, 158, 53),
    (6, 57, 83),
    (109, 67, 85),
    (113, 161, 175),
    (22, 122, 174),
    (64, 153, 138),
    (39, 36, 36),
    (76, 40, 48),
    (9, 67, 47),
    (90, 141, 53),
    (181, 96, 79),
    (132, 40, 42),
    (210, 200, 151),
    (141, 171, 155),
    (179, 201, 186),
    (172, 153, 159),
    (212, 183, 177),
    (176, 198, 203),
]

GAP_SIZE = 50
X_AXIS = -250
Y_AXIS = -250
DOT_SIZE = 20
ROWS = 10
COLUMNS = 10

tim = t.Turtle()
tim.speed("fast")
tim.penup()
t.colormode(255)
tim.hideturtle()
tim.setposition(X_AXIS, Y_AXIS)

for row in range(ROWS):
    tim.left(90)
    tim.forward(GAP_SIZE)
    tim.setx(X_AXIS)
    tim.right(90)
    for column in range(COLUMNS):
        tim.dot(DOT_SIZE, rd.choice(color_list))
        tim.forward(GAP_SIZE)

screen = t.Screen()
screen.exitonclick()
