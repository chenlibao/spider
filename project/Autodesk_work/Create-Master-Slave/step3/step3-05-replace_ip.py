import os
import re
import socket

'''
def replace_ipInFile_to_localIp(_path):
    local_ip = socket.gethostbyname(socket.getfqdn(socket.gethostname()))

    new_file = ""
    with open(_path, 'r', encoding="utf-8") as file:
        content = file.read().splitlines()
        pattern = re.compile('/testController:"(?P<server>(\d{1,3}\.){3}\d{1,3}):\d{1,5}', re.I)

        for line in content:
            result = pattern.search(line)
            if result is not None:
                server = result.group('server')
                line = line.replace(server, local_ip)
            new_file += line + "\n"

    with open(_path, 'w', encoding="utf-8") as file:
        file.write(new_file)
'''


def replace_words_in_file(_path, old, new):
    new_file = ""
    with open(_path, 'r', encoding="utf-8") as file:
        content = file.read().splitlines()

        for line in content:
            if old in line:
                line = line.replace(old, new)
            new_file += line + "\n"

    with open(_path, 'w', encoding="utf-8") as file:
        file.write(new_file)


local_ip = socket.gethostbyname(socket.getfqdn(socket.gethostname()))

paths = (r"C:\JenkinsSlaveKit\BatchFiles\connectToTestController.bat",
         r"C:\JenkinsSlaveKit\BatchFiles\setupForTestAgent.bat",
         r"C:\JenkinsSlaveKit\JenkinsSMMachineMaker\setup.bat",
         r"C:\JenkinsSlaveKit\BatchFiles\copyOutput.ps1",
         r"C:\JenkinsSlaveKit\BatchFiles\setupQ.bat")

for path in paths:
    replace_words_in_file(path, "10.49.83.96", local_ip)
