import tkinter as tk
from tkinter import ttk

inputmode = "miles"

def calculate():
    global inputmode
    converting_value = float(converting.get())
    if inputmode == "miles":
        converted.set(str(round(converting_value * 1.6)))
    else:
        converted.set(str(round(converting_value / 1.6)))


def swap():
    global inputmode
    if inputmode == "miles":
        main_lbl.config(text="From kilometres to miles")
        inputmode = "kilometers"
    else:
        main_lbl.config(text="From miles to kilometres")
        inputmode = "miles"
    temp = converting.get()
    converting.set(converted.get())
    converted.set(temp)


root = tk.Tk()
root.title("Miles to kilometers")
root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)

mainframe = ttk.Frame(root)
mainframe.grid(column=0, row=0, sticky='nwse')

main_lbl = ttk.Label(mainframe, text="From miles to kilometres")
main_lbl.grid(column=1, row=0, pady=10, columnspan=3)

converting = tk.StringVar()
converting_entry = ttk.Entry(mainframe, width=6, textvariable=converting)
converting_entry.grid(column=1, row=1, sticky='w')

btn_switch = ttk.Button(mainframe, text='Swap', command=swap)
btn_switch.grid(column=2, row=1)

converted = tk.StringVar()
converted_entry = ttk.Entry(mainframe, width=6, textvariable=converted, state='readonly')
converted_entry.grid(column=3, row=1, sticky='e')

btn_calculate = ttk.Button(mainframe, text='Calculate', command=calculate)
btn_calculate.grid(column=2, row=2)

root.mainloop()