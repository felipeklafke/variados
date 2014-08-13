#!/bin/sh

#Desinstala e instala os programas que existem no banco de dados do PKG.

programas=$(pkg info -x "^[a-z]" | grep -v pkg)
pkg delete -y $programas
pkg install -y $programas