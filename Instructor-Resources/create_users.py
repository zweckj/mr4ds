import subprocess, crypt

with open('credentials.csv') as f:
    for line in f:
        i = line.find(',')
        name = line[:i]
        password = line.rstrip()[i+1:]
        encpt_passwd = crypt.crypt(password, '2b')
        command = 'useradd -m -p {0} {1}'.format(encpt_passwd, name).split()
        subprocess.call(command)
