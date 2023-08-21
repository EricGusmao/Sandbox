import turtle as t
import random as rd


is_race_on = False
screen = t.Screen()
screen.setup(width=500, height=400)
user_bet = screen.textinput(
    title="Make your bet", prompt="Which turtle will win the race? Enter a color:"
)
COLORS = ["red", "orange", "yellow", "green", "blue", "purple"]
Y_POSITIONS = [-70, -40, -10, 20, 50, 80]
all_turtles = []
for turtle_index in range(0, 6):
    new_turtle = t.Turtle(shape="turtle")
    new_turtle.color(COLORS[turtle_index])
    new_turtle.penup()
    new_turtle.goto(x=-230, y=Y_POSITIONS[turtle_index])
    all_turtles.append(new_turtle)
if user_bet:
    is_race_on = True
while is_race_on:
    for turtle in all_turtles:
        if turtle.xcor() > 230:
            is_race_on = False
            winning_color = turtle.pencolor()
            if winning_color == user_bet:
                print(f"You've won! The {winning_color} turtle is the winner!!!")
            else:
                print(f"You've lost! The {winning_color} turtle is the winner!!!")
        rand_distance = rd.randint(0, 10)
        turtle.forward(rand_distance)

screen.exitonclick()
