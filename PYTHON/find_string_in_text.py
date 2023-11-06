import re

class FindStringInText:
    def __init__(self, word: str):
        self.word = word
        self.regex_expression = self.regex(word)
        self.string_number = 1
        self.result = {}

    def regex(self, word: str) -> str:
        regex = "^"
        for ch in word:
            regex += f"(?=.*[{ch.lower()}])"   
        return regex + ".*$"

    def find_string(self, string: str) -> list:
        _ = re.findall(self.regex_expression, string.lower())
        if _:
            self.result[self.string_number] = _[0]
        self.string_number += 1
        return self.result

    def mark_simbol(self) -> str:
        for key in self.result:
            for _ in self.word:
                self.result[key] = re.sub(_, f'[{_.upper()}]', self.result[key])  
        return self.result

    def __str__(self):
        return f'{self.result}'

word = 'minkov'
result = FindStringInText(word)

with open('text.txt', 'r') as f:
    for line in f.readlines():
        result.find_string(line)

print(result)
print()
print(result.mark_simbol())
