import subprocess

filename = "/var/log/apache2/other_vhosts_access.log"

def count(ip):
        co = 0
        f = open(filename, "r")
        for line in f:
                if ip in line:
                        co = co + 1 
        return(co)                     

f = subprocess.Popen(['tail','-F',filename],\
        stdout=subprocess.PIPE,stderr=subprocess.PIPE)
while True:
    line = f.stdout.readline()
    line = str(line)
    line_split = line.split(" ")
    ip = line_split[1]
    cao = count(ip)
    if cao > 20:
        print("O IP "+ip +" ja coletou "+str(cao)+" objetos no servidor") 
