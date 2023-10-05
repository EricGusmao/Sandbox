import tkinter as tk
from tkinter import ttk, messagebox
from random import choice, randint, shuffle
import pyperclip

LETTERS = [
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
]
NUMBERS = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
SYMBOLS = ["!", "#", "$", "%", "&", "(", ")", "*", "+"]


# ---------------------------- PASSWORD GENERATOR ------------------------------- #
# Password Generator Project
def generate_password():
    password_letters = [choice(LETTERS) for _ in range(randint(8, 10))]
    password_symbols = [choice(SYMBOLS) for _ in range(randint(2, 4))]
    password_numbers = [choice(NUMBERS) for _ in range(randint(2, 4))]
    password_list = password_letters + password_symbols + password_numbers

    shuffle(password_list)

    password = "".join(password_list)
    pyperclip.copy(password)
    entry_password.delete(0, "end")
    return entry_password.insert(0, password)


# ---------------------------- SAVE PASSWORD ------------------------------- #
def save():
    website = input_website.get()
    user = input_user.get()
    password = input_password.get()
    if not website or not user or not password:
        return messagebox.showerror(
            title="Oops", message="Please don't leave any fields empty!!!"
        )

    is_ok = messagebox.askokcancel(
        title=website,
        message=f"These are the details entered: \nEmail: {user} \nPassword: {password} \nIs it ok to save?",
    )
    if is_ok:
        with open("./password-manager/data.txt", "a") as data:
            data.write(f"{website} || {user} || {password}\n")
        entry_website.delete(0, "end")
        entry_password.delete(0, "end")


# ---------------------------- UI SETUP ------------------------------- #
root = tk.Tk()
root.title("Password Manager")
root.config(padx=50, pady=50)
root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)

canvas = tk.Canvas(root, width=200, height=200)
canvas.grid(column=1, row=0)
logo_img = tk.PhotoImage(file="./password-manager/logo.png")
canvas.create_image(100, 100, image=logo_img)

lbl_website = ttk.Label(root, text="Website:")
lbl_website.grid(row=1, column=0, sticky="e")

input_website = tk.StringVar()
entry_website = ttk.Entry(root, width=40, textvariable=input_website)
entry_website.grid(column=1, row=1, columnspan=2)
entry_website.focus()

lbl_user = ttk.Label(root, text="Email/Username:")
lbl_user.grid(row=2, column=0, sticky="e")

input_user = tk.StringVar()
entry_user = ttk.Entry(root, width=40, textvariable=input_user)
entry_user.grid(column=1, row=2, columnspan=2)
entry_user.insert(0, "johndoe@gmail.com")

lbl_password = ttk.Label(root, text="Password:")
lbl_password.grid(row=3, column=0, sticky="e")

input_password = tk.StringVar()
entry_password = ttk.Entry(root, width=23, textvariable=input_password)
entry_password.grid(column=1, row=3)

btn_generate = ttk.Button(root, text="Generate Password", command=generate_password)
btn_generate.grid(column=2, row=3)

btn_add = ttk.Button(root, text="Add", command=save, width=40)
btn_add.grid(column=1, row=4, columnspan=2)

root.mainloop()
