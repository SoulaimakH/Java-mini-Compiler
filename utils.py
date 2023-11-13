import os
import subprocess 

def write_file(content,filename):
    f = open(filename,"w")
    f.write(content)
    f.close()

def read_file(filename):
    f = open(filename,"r")
    content = f.read()
    return content

def remove_files():
    dir_path = "Compiler/"
    files_to_remove = ["Script.txt", "Output.txt" , "Error.txt"]
    for file in files_to_remove:
        file_path = os.path.join(dir_path, file)
        os.remove(file_path)

def remove_empty_lines(filename):

    with open(filename, 'r') as file:
        lines = file.readlines()
    
    non_empty_lines = [line for line in lines if line.strip() != '']

    with open(filename, 'w') as file:
        file.writelines(non_empty_lines)

def removeStrings(filename,string):
    with open(filename, 'r') as file:
        contents = file.read()

    modified_contents = contents.replace(string, '')

    with open(filename, 'w') as file:
        file.write(modified_contents)

def execute_command(command , inputfile , outputfile ):
    with open(inputfile) as file, open(outputfile, 'w') as outfile , open("Compiler/Error.txt", 'w') as errfile:
        try:
            subprocess.check_call([command],stdin=file, stdout=outfile, stderr=errfile)
        except subprocess.CalledProcessError as e:
            # Handle the error
            print('error')
    
    #removeStrings(outputfile,'COMMENT BLOCK')

    return read_file(outputfile) , read_file("Compiler/Error.txt")


def remove_dupp(sam_list):
    result = [] 
    for i in sam_list: 
        if i not in result: 
            result.append(i)
    result.pop(0)
    return result

def get_Table():
    tableEl = []
    table = read_file("Compiler/Output.txt")
    lines = table.split('\n')
    lines.pop()
    for line in lines:
        line = line.split('|')
        tableEl.append(line)
    
    return remove_dupp(tableEl)
