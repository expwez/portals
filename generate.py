import os
import sys
from watchgod import watch


def compile():
    moduleContent = ''

    with open("./src/module.lua", 'r') as file:
        moduleContent = file.read()

    files = os.listdir('./src/textareas')

    for file in files:
        replaceString = f'{{{{textareas/{file}}}}}'

        if not (replaceString in moduleContent):
            continue

        fileContent = ''

        with open(f"./src/textareas/{file}") as file:
            fileContent = "".join(line.rstrip() for line in file)
            fileContent = fileContent.replace("\t", "").replace('   ', '')

        moduleContent = moduleContent.replace(replaceString, fileContent)

    with open("./dist/compiled.lua", "w") as f:
        f.write(moduleContent)


compile()
print(f'Compiled successfully.')

if (len(sys.argv) > 1 and sys.argv[1] == "--watch"):
    for changes in watch('./src'):
        print(f'Got change {changes}, compiling...')
        compile()
        print(f'Compiled successfully.')
