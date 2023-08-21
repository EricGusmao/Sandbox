import turtle as t
import random


def random_colour():
    r = random.randint(0, 255)
    g = random.randint(0, 255)
    b = random.randint(0, 255)
    colour = (r, g, b)
    return colour


tim = t.Turtle()
t.colormode(255)
tim.speed("fastest")


def draw_spirograph(size_of_gap):
    for _ in range(360 // size_of_gap):
        tim.color(random_colour())
        tim.circle(100)
        tim.setheading(tim.heading() + size_of_gap)


draw_spirograph(50)


screen = t.Screen()
screen.exitonclick()
