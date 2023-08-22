import pandas

alphabet_file = pandas.read_csv("./NATO-alphabet-start/nato_phonetic_alphabet.csv")
alphabet = {row.letter: row.code for (index, row) in alphabet_file.iterrows()}
word = input("Enter a word: ").upper()
result = [alphabet[letter] for letter in word]
print(result)
