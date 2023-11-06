import re

class FindStringInText:
    def __init__(self, word: str):
        self.word = word
        self.regex_expression = self.regex(word)
        self.result = []

    def regex(self, word: str) -> str:
        regex = "^"
        for ch in word:
            regex += f"(?=.*[{ch.lower()}])"   
        return regex + ".*$"

    def find_string(self, string: str) -> list:
        self.result.append(re.findall(self.regex_expression, string.lower()))
        return self.result

    def __str__(self):
        return f'{self.result}'
    

word = 'minkov'
result = FindStringInText(word)
i=1

with open('text.txt', 'r') as f:
    for line in f.readlines():
        result.find_string(f'{i}  {line}')
        i+=1

print(result)
