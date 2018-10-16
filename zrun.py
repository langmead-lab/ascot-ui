import subprocess

subprocess.run('sudo ./kill.sh', shell=True)
subprocess.run('sudo ./build.sh', shell=True)
subprocess.run('sudo ./run.sh', shell=True)

