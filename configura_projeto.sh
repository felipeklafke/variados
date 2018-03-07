#!/bin/bash
<<<<<<< HEAD
<<<<<<< HEAD
#
#Monta o ambiente de uma nova app com nginx
=======

#Monta o ambiente de uma nova app
>>>>>>> 375c85685966ffaa5720949d8e98506ffc169459
=======

#Monta o ambiente de uma nova app
>>>>>>> 375c85685966ffaa5720949d8e98506ffc169459
#
# - Pegar nome da app, dominio e camingo do diretorio raiz
# - Criar diretorios raiz (padroes)
# - Monta ambiente virtual com virtualenv
# - Gerar arquivos padroes:
#    - nginx: nomeapp
#    - uwsgi: nomeapp.ini
#    - uwsgi da app: nomeapp.py
#    - dns: primario e reverso


echo '
========================================================
||Executar esse script com permissao de root          ||
||Script para montar a estrutura da aplicacao         ||
========================================================
'


nome_app=''
dominio=''
criar_em=''
raiz_programas='/etc'
usuario=''
data_atual=$(date +%y%m%d%H%M)
ip_a='177.70.26.51'
ip_b='177.70.21.102'

while true; do
    read -p 'Qual o nome da app? ' nome_app
    if [ ! -z $nome_app ]; then
         break;
    fi
done

while true; do
    read -p 'Qual o dominio da app? ' dominio
    if [ ! -z $dominio ]; then
         break;
    fi
done

while true; do
    read -p 'Qual a pasta raiz da app? [default: /projetos]: ' criar_em
    if [ -z $criar_em ]; then
         criar_em='/projetos'
         break;
    else
        break;
    fi
done

pergunta() {
    #perguntas com resposta de sim ou nao [1 e 0]
    #$1 = pergunta para o usuario
    while true; do
        read -p "$1 (s/n): " resp
        case $resp in
            [Ss]* ) return 1; break;;
            [Nn]* ) return 0;;
            * ) echo 'Digite s ou n!!!!!!!!!!!!!!';;
        esac
    done
}

pergunta 'Servidor local?'
if [ $? -eq 1 ]; then
    usuario="felipe"
else
    usuario="www-data"
fi

criar_diretorios_padroes() {
    if mkdir $criar_em/$nome_app &&
    cd $criar_em/$nome_app && mkdir core log sql controllers static tmp templates &&
    cd $criar_em/$nome_app/static && mkdir js css img &&
    cd $criar_em/$nome_app && touch readme.txt uwsgi.py .gitignore;
    then
        echo 'Diretorios criados com sucesso!'
    else
        echo 'Erro ao criar diretorio!'
    fi

    #define donos da pasta do projeto
    if chown -R $usuario:www-data $criar_em/$nome_app; then
        echo 'Acessos definidos!'
    else
        echo 'Erro ao definir acesso em pasta do aplicativo!'
    fi

    #define permissoes da pasta do projeto
    if chmod -R a-wrx,o-rwx,u+wrx,g+wrx $criar_em/$nome_app; then
        echo 'Permissoes definidas com sucesso!'
    else
        echo 'Erro ao definir permissoes!'
    fi

gitignore="
py2env
build
*.pyc
.git
.
"
echo "$gitignore" > $criar_em/$nome_app/.gitignore


}

gerar_arquivo_config_nginx() {
    conteudo_basico="server {
    root $criar_em/$nome_app;
        server_name $dominio;
        listen 80;
        location / {
            uwsgi_pass unix://$criar_em/$nome_app/tmp/$nome_app.sock;
            include uwsgi_params;
        }
    }
    "

    if echo "$conteudo_basico" > $raiz_programas/nginx/sites-enabled/$nome_app; then
        echo 'Nginx configurado!'
    else
        echo 'Nginx nao pode ser configurado!'
    fi
}


gerar_arquivo_config_uwsgi() {
    conteudo_basico="
[uwsgi]
virtualenv=$criar_em/$nome_app/py2env
chdir=$criar_em/$nome_app
master=1
socket=$criar_em/$nome_app/tmp/$nome_app.sock
damonize=$criar_em/$nome_app/log/uwsgi_$nome_app.log
wsgi-file=$criar_em/$nome_app/uwsgi.py
plugins=python
processes=1
uid=33
gid=33
threads=1
    "

    if echo "$conteudo_basico" > $raiz_programas/uwsgi/apps-enabled/$nome_app.ini; then
        echo 'Uwsgi configurado!'
    else
        echo 'Uwsgi nao pode ser configurado!'
    fi
}

gerar_arquivo_config_app_uwsgi() {
    conteudo_basico="
# -*- coding:utf-8 -*-

import cherrypy


class Rotas:
    def __init__(self):
        pass

    @cherrypy.expose
    def index(self):
        return 'HelloWorld'

def application(environ, start_response):
    cherrypy.tree.mount(Rotas(), '/')
    return cherrypy.tree(environ, start_response)
    "

    if echo " $conteudo_basico" > $criar_em/$nome_app/uwsgi.py; then
        echo 'Arquivo uwsgi.py configurado com sucesso!'
    else
        echo 'Falha ao configurar arquivo uwsgi.py!'
    fi
}

gerar_arquivo_config_dns() {
    conteudo_basico_primario="
"\$TTL" 3h
$nome_app. IN SOA server1.$nome_app. felipeklafke@live.com.br (
    $data_atual; serial
    2h;28800; refresh, seconds
    900;7200; retry, seconds
    1w;1209600; expiry, seconds
    3h);86400); minimum-TTL, seconds

@ IN NS server1.$nome_app.
@ IN NS server2.$nome_app.

server1 IN A $ip_a
server2 IN A $ip_b

www IN A $ip_a
www IN A $ip_b
    "
    conteudo_basico_reverso="
//zone $dominio
//
zone "\""$dominio"\"" {
    type master;
    file "\""$raiz_programas/bind/zonas/pri.$dominio"\"";
    allow-update {none;};
    allow-transfer {none;}
};
    "

    #define primario
    if echo "$conteudo_basico_primario" > $raiz_programas/bind/zonas/pri.$nome_app; then
        echo 'Arquivo DNS primario criado/alterado com sucesso!'
    else
        echo 'Erro ao criar arquivo DNS primario!'
    fi

    #define reverso
    if echo "$conteudo_basico_reverso" >> "$raiz_programas/bind/named.conf.local"; then
        echo 'Arquivo DNS reverso alterado com sucesso!'
    else
        echo 'Error ao criar DNS reverso!'
    fi

}

#diretorios raiz
pergunta 'Deseja criar os diretorios padroes e aplicar suas permissoes?'
if [ $? -eq 1 ]; then
    criar_diretorios_padroes
fi

#gerar arquivo de configuracao do nginx
pergunta 'Deseja configurar o nginx?'
if [ $? -eq 1 ]; then
    gerar_arquivo_config_nginx
fi

#gerar configuracao uwsgi
pergunta 'Deseja configurar o uwsgi?'
if [ $? -eq 1 ]; then
    gerar_arquivo_config_uwsgi
fi

#gerar configuracao da app do uwsgi
pergunta 'Deseja configurar uwsgi do app?'
if [ $? -eq 1 ]; then
    gerar_arquivo_config_app_uwsgi
fi

#gerar arquivo dns primario e reverso
if [ "$usuario" = "www-data" ]; then
    pergunta 'Deseja configurar dns primeiro e reverso?'
    if [ $? -eq 1 ]; then
        gerar_arquivo_config_dns
    fi
fi

#configura virtualenv
<<<<<<< HEAD
#if virtualenv $criar_em/$nome_app/py2env; then
#    echo 'VirtualEnv criado com sucesso!'
#    
#    read -p "Insira o nome de uma dependencia para ser instalada via pip? (digite sair): " resp
#    #if [ ! -z $resp ]; then
#        #eval ". $criar_em/$nome_app/py2env/bin/activate && pip install $resp && deactivate"        
#    #fi        #

#else
#    echo 'Ambiente virtual nao pode ser configurado!'
#fi
=======
pergunta 'Criar ambiente com virtualenv?'
if [ $? -eq 1 ]; then
    if virtualenv $criar_em/$nome_app/py2env; then
        echo 'VirtualEnv criado com sucesso!'
        while true; do
            read -p 'Insira o nome de uma dependencia para instalar via pip? (digite sair): ' resp
            if [ ! -z $resp ] && [ "$resp" != "sair" ]; then
                eval ". $criar_em/$nome_app/py2env/bin/activate && pip install $resp && deactivate"
            elif [ ! -z $resp ] && [ "$resp"="sair" ]; then
                break;
            fi
        done
    else
        echo 'Ambiente virtual nao pode ser configurado!'
    fi
fi


#criar base de dados no mysql
pergunta 'Deseja criar a base de dados padrÃ£o?'

script="

"
<<<<<<< HEAD
>>>>>>> parent of 4171245... inserido script sql para criacao de bd mysql
=======
>>>>>>> parent of 4171245... inserido script sql para criacao de bd mysql


#reinicia servicos
pergunta 'Deseja reiniciar o nginx?'
if [ $? -eq 1 ]; then
    service nginx restart
fi

pergunta 'Deseja reiniciar o uwsgi?'
if [ $? -eq 1 ]; then
    service uwsgi restart
fi



echo '
=======================================================
||Configuracoes finalizadas!                         ||
||Se constarem erros, execute esse script novamente! ||
=======================================================
'


exit 1
