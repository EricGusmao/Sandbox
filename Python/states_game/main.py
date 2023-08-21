import turtle, pandas

screen = turtle.Screen()
states_file = pandas.read_csv("./states_game/50_states.csv")
states = states_file["state"].tolist()
correct_guesses = []
screen.title("U.S. States Game")
image = "./states_game/blank_states_img.gif"
screen.addshape(image)

turtle.shape(image)


while len(correct_guesses) < 50:
    answer_state = str(
        screen.textinput(
            title=f"{len(correct_guesses)}/50", prompt="What's another state's name??"
        )
    ).title()

    if answer_state == "Exit":
        missing_states = [state for state in states if state not in correct_guesses]
        new_data = pandas.DataFrame(missing_states)
        new_data.to_csv("states_to_learn.csv")
        break
    if answer_state in states and answer_state not in correct_guesses:
        correct_guesses.append(answer_state)
        row = states_file[answer_state == states_file.state]
        coor = (int(row.x), int(row.y))
        t = turtle.Turtle()
        t.hideturtle()
        t.penup()
        t.goto(coor)
        t.write(answer_state)


screen.exitonclick()
