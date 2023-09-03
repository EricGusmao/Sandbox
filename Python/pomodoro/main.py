import tkinter as tk
from tkinter import ttk
from math import floor

# ---------------------------- CONSTANTS ------------------------------- #
PINK = "#e2979c"
RED = "#e7305b"
GREEN = "#9bdeac"
YELLOW = "#f7f5dd"
FONT_NAME = "Courier"
WORK_MIN = 25
SHORT_BREAK_MIN = 5
LONG_BREAK_MIN = 20
reps = 0
timer = None
# ---------------------------- TIMER RESET ------------------------------- #


def reset_timer():
    global reps
    root.after_cancel(timer)
    canvas.itemconfig(timer_text, text="00:00")
    lbl_title.config(text="Timer")
    checkmarks.config(text="")
    reps = 0


# ---------------------------- TIMER MECHANISM ------------------------------- #


def start_timer():
    global reps
    reps += 1
    work_sec = WORK_MIN * 60
    short_break_sec = SHORT_BREAK_MIN * 60
    long_break_sec = LONG_BREAK_MIN * 60
    if reps % 2 != 0:
        count_down(work_sec)
        lbl_title.config(text="Work", foreground=GREEN)
    elif reps == 8:
        count_down(long_break_sec)
        lbl_title.config(text="Break", foreground=RED)
    else:
        count_down(short_break_sec)
        lbl_title.config(text="Break", foreground=PINK)


# ---------------------------- COUNTDOWN MECHANISM ------------------------------- #


def count_down(count):
    global timer
    count_min = floor(count / 60)
    count_sec = count % 60
    if count_sec < 10:
        count_sec = f"0{count_sec}"
    canvas.itemconfig(timer_text, text=f"{count_min}:{count_sec}")
    if count > 0:
        timer = root.after(1000, count_down, count - 1)
    else:
        start_timer()
        marks = ""
        work_sessions = floor(reps / 2)
        for _ in range(work_sessions):
            marks += "✔"
        checkmarks.config(text=marks)


# ---------------------------- UI SETUP ------------------------------- #
root = tk.Tk()
root.title("Pomodoro")
root.config(padx=100, pady=50, background=YELLOW)
root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)

lbl_title = ttk.Label(
    root, text="Timer", background=YELLOW, foreground=GREEN, font=(FONT_NAME, 50)
)
lbl_title.grid(column=1, row=0)

canvas = tk.Canvas(root, width=200, height=224, background=YELLOW, highlightthickness=0)
canvas.grid(column=1, row=1)
tomato_img = tk.PhotoImage(file="Python/pomodoro/tomato.png")
canvas.create_image(100, 112, image=tomato_img)
timer_text = canvas.create_text(
    100, 130, text="00:00", fill="white", font=(FONT_NAME, 35, "bold")
)


btn_start = ttk.Button(root, text="Start", command=start_timer)
btn_start.grid(row=2, column=0)

btn_reset = ttk.Button(root, text="Reset", command=reset_timer)
btn_reset.grid(row=2, column=2)

checkmarks = ttk.Label(root, text="", foreground=GREEN, background=YELLOW)
checkmarks.grid(column=1, row=3)

root.mainloop()
