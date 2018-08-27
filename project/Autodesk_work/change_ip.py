import socket


def change_ip(file, old_ip, new_ip):
    new_line = ""
    with open(file, 'r') as f:
        for line in f.readlines():
            if old_ip in line:
                line = line.replace(old_ip, new_ip)
            new_line = new_line + line + "\n"

    with open(file, 'w') as ft:
        ft.write(new_line)


if __name__ == "__main__":
    files = [
        r'C:\Users\t_chenli\Desktop\practice_vault_setupEnv\JenkinsSlaveKit_Copy\BatchFiles\connectToTestController.bat',
        r'C:\Users\t_chenli\Desktop\practice_vault_setupEnv\JenkinsSlaveKit_Copy\BatchFiles\setupForTestAgent.bat',
        r'C:\Users\t_chenli\Desktop\practice_vault_setupEnv\JenkinsSlaveKit_Copy\JenkinsSMMachineMaker\setup.bat',
        r'C:\Users\t_chenli\Desktop\practice_vault_setupEnv\JenkinsSlaveKit_Copy\BatchFiles\copyOutput.ps1',
        r'C:\Users\t_chenli\Desktop\practice_vault_setupEnv\JenkinsSlaveKit_Copy\BatchFiles\setupQ.bat'
    ]
    new_ip = socket.gethostbyname(socket.gethostname())
    for file in files:
        change_ip(file, '10.49.83.96', new_ip)