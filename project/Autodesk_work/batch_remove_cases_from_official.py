# coding=utf-8
import json
import re

"""
Remove "inventorOEM" value from .prop file which is a json file.
If it just include "inventorOEM", we write it to a .txt file and remove .prop, .tf/tc, .xml from local
"""


def get_file_paths(test_case):
    with open(test_case, 'r', encoding='utf-8') as tc:
        file_paths = tc.readlines()
        set_data(file_paths)


def set_data(file_paths):
    for path in file_paths:
        file_path = path.strip()

        with open(file_path, 'rb') as f:
            data = json.load(f)
            data['Group']['Products'].remove('InventorOEM')
            update_data = data
            write_data(update_data, file_path)
            if len(update_data['Group']['Products']) == 0:
                get_remove_cases(update_data, file_path)


def get_remove_cases(update_data, file_path):
    test_file = re.sub(r'.*?:\\transcripts\\regression',
                       r'D:\\P4\\inventor\\main\\QA\\transcripts\\regression',
                       update_data["FullTestFilePath"])
    xml_file = test_file.split('.')[0] + '.xml'
    remove_file = test_file + '\n' + xml_file + '\n'
    remove_file1 = file_path + '\n'

    with open(r'C:\Users\t_chenli\Desktop\remove_cases\remove_cases.txt', 'a') as rc:
        rc.write(remove_file)
    with open(r'C:\Users\t_chenli\Desktop\remove_cases\remove_cases1.txt', 'a') as rc1:
        rc1.write(remove_file1)


def write_data(update_data, file_path):
        file = open(file_path, 'w')
        json.dump(update_data, file, indent=2)
        file.close()


if __name__ == "__main__":
    test_case = r'C:\Users\t_chenli\Desktop\remove_cases\testfile.txt'
    get_file_paths(test_case)