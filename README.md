# desafio

[OBJETIVO]
A proposta desse projeto é uma aplicacao .gif com Apache e php com garantia de disponibilidade e escalabilidade usando AWS e terraform com script Python para monitoracao
de quantidade de acesso.

Temos uma pagina php com autenticacao via Token, essa nossa aplicacao será implementada em nossas maquinas EC2 e teremos um Load Balancer monitorando a porta 80 de 30
em 30 segundos.
Se nossa aplicacao nao responder nesse tempo, o Load ira criar uma nova instancia em outra AZ.


[DETALHES DO PROJETO]

Nesse projeto usamos os respectivos recursos:

•	EC2 – Para provisionamento das máquinas;
•	VPC – Para provisionamento das Subnets; 
•	ASG – Para provisionamento do nosso Load Balanced;

[COMO CONFIGURAR]
1 Baixe esse diretorio do GIT no seu computador.
2 Criar um usuario la no Identity and Access Management (IAM) na AWS, apos isso coletar o access_key e secret_key e colocar-los no arquivo main.tf.
3 Apos isso descompacte e rode o comando: 
terraform plan (Se voce quiser ver o plano de execucao da infra) 

e depois 

terraform apply (Que aplicará as configuracoes contidas no arquivo create.tf la na AWS) 

4 Após execução do comando terraform apply para criação da nossa infra, vamos fazer deploy da nossa aplicação:
4.1 Vamos copiar a aplicação para as duas máquinas “terraform-asg-megatron” e “terraform-megatron” que foram criadas la na nossa conta na AWS.
Precisamos subir nossa aplicação para o servidor.

A aplicação está zipada com nome: config.zip
scp -i "my-key.pem" config.zip USUARIO@NOME_DA_MAQUINA:/home/USUARIO

O comando acima copia a nossa aplicação para a pasta /home/USUARIO lá no nosso servidor, vamos entrar no servidor com o comando abaixo:

ssh -i "my-key.pem" USUARIO@NOME_DA_MAQUINA

Apos isso vamos instalar o apache + php e unzip em nosso servidor:

sudo apt-get install apache2 libapache2-mod-php unzip

Iniciar nosso serviço:

sudo /etc/init.d/apache2 start

Descompactar o pacote:

unzip config.zip

Vamos copiar nossa aplicação para a pasta de padrão do apache:

sudo mv config/* /var/www/html/

Após isso, vamos acessar via navegador com o nosso DNS do Load Balanced:

clb_dns_name = DNS_DO_LOAD_BALANCER

Fiz o nosso script terraform cuspir ele no final da execução do nosso código:

output "clb_dns_name" {
  value       = aws_elb.megatron.dns_name


[LOAD BALANCER]
Para verificar que o nosso Load Balancer está funcionando corretamente, vamos seguir o passo a passo:
Detalhes técnicos da configuração do Balancer:
	
Tipo de Load Balancer: Classic Load Balancer (CLB)
interval de verificacao:	30 Segundos

	 
Configurei um load balancer que monitora a porta 80 da nossa aplicação, HTTP://80
Em um intervalo de 30 segundos como informado no inicio desse arquivo, se a nossa aplicação não responder ele irá criar uma nova instancia nas AZs configuradas 
no arquivo create.tf.

availability_zones = ["us-east-1c", "us-east-1d", "us-east-1b", "us-east-1f", "us-east-1a", "us-east-1e"]

[SEGURANCA]
Para garantir ainda mais a seguranca da nossa aplicacao, temos um script Python que monitora o access.log do Apache, caso um IP tente coletar mais 20 vezes um 
objeto em nossa aplicacao nosso script irá informar.
Voce pode usar isso para gerar alertas de monitoracao e tambem verificar os IPS que mais acessam sua aplicacao :).

Veja alguns detalhes do scrip:

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

Saida do script:
O IP XXX.XXX.XXX.XXX ja coletou 28 objetos no servidor
Voce pode aumentar esse controle para um numero maior se preferir.


