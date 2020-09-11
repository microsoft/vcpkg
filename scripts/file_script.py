import os
import os.path
import sys


keyword = "include/"

def getFiles(path):
    files = os.listdir(path)
    return list(filter(lambda x: x[0] != '.', files))

def gen_all_file_strings(path, files, headers, output):
    for file in files:
        package = file[:file.find("_")]
        f = open(path + file)
        for line in f:
            idx = line.strip().find(keyword)
            if idx >= 0 and line.strip()[-1] != "/":
                headers.write(package + ":" + line[idx + len(keyword):])
                output.write(package + ":" + line[idx-1:])
            elif line.strip()[-1] != "/":
                output.write(package + ":" + line[line.find("/"):])
        f.close()

def main(path):
    try:
        os.mkdir("scripts/list_files")
    except FileExistsError:
        print("Path already exists, continuing...")

    try:
        headers = open("scripts/list_files/VCPKGHeadersDatabase.txt", mode='w')
        output = open("scripts/list_files/VCPKGDatabase.txt", mode='w')
        gen_all_file_strings(path, getFiles(path), headers, output)
        headers.close()
        output.close()
    except e:
        print("Failed to generate file lists")

if __name__ == "__main__":
    main(sys.argv[1])

