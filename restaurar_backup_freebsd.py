#!/bin/python


"""
Desinstala e instala os programas do banco de dados do gerenciador de pacotes PKG do freeBSD.
Apenas irá afetar os que não estiverem "locados"(in lock).
"""

import os
import subprocess

programas = subprocess.Popen("pkg info -ak | grep no", stdout=subprocess.PIPE, shell=True)
(output, err) = programas.communicate()
p_status = programas.wait()

lista = output.split(" ")
auxlista = []

for a in lista:
    a = a.strip()
    if a!= "":
        a = a.replace("no\n", "")
        a = a.strip()
        if len(a) > 3:
            auxlista.append(a)


for a in auxlista:
    os.system("pkg delete -y {0}".format(a))
    os.system("pkg install -y {0}".format(a))
