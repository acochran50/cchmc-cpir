"""file_compare.py

Returns the differences between two input files to sys.stdout. Formatted for use as a
standalone CLI script; not an import-ready module.

Alex Cochran, 2018.
"""

import os
import sys
import difflib

INPUT_PATH = os.getcwd()


def read_files(input_path=INPUT_PATH):
    """Read files that are to be compared."""

    print("\nSpecify files for comparison. Must be in the current working directory.")
    filename_1 = "\\" + input("\n\tFile 1: ")
    filename_2 = "\\" + input("\tFile 2: ")

    try:
        with open(INPUT_PATH + filename_1, mode='r') as file_in:
            file_1_data = []
            for line in file_in:
                file_1_data.append(line)

    except FileNotFoundError:
        print("File 1 was not found. Check your inputs and try again.")

    try:
        with open(INPUT_PATH + filename_2, mode='r') as file_in:
            file_2_data = []
            for line in file_in:
                file_2_data.append(line)

    except FileNotFoundError:
        print("File 2 was not found. Check your inputs and try again.")

    return file_1_data, file_2_data
    

def check_diff(list_1, list_2):
    """Provides the diff report for two files given as the funciton input."""

    send_to_file = input("\nSend output to a text file? [y/N]: ")
    print(send_to_file)

    diff_op = difflib.unified_diff(list_1, list_2, fromfile="File 1", tofile="File 2", lineterm="", n=0)

    for line in diff_op:
        print(line)


def main():
    """Perform diff operation."""

    file_1_data, file_2_data = read_files()
    check_diff(file_1_data, file_2_data)


if __name__ == '__main__':
    main()
