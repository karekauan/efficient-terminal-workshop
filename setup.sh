#!/bin/bash

# Cores para o output do terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Iniciando a preparação do ambiente para o Workshop...${NC}\n"

WORK_DIR="workshop_terminal"
echo -e "${YELLOW}[1/5] Criando diretórios base em ./${WORK_DIR}...${NC}"
mkdir -p ${WORK_DIR}/{pratica_basica,ctf1_sistema,ctf2_logs,dicas}

# ==========================================
# 1. CRIANDO ARQUIVOS PARA PRÁTICA BÁSICA
# ==========================================
echo -e "${YELLOW}[2/5] Gerando arquivos curtos para treino de comandos básicos...${NC}"

# Para testar o 'wc' (contagem visível e rápida)
cat <<EOF > ${WORK_DIR}/pratica_basica/poema.txt
Batatinha quando nasce
Espalha a rama pelo chao
A menina quando dorme
Poe a mao no coracao
EOF

# Para testar 'head' e 'tail'
seq 1 30 | sed 's/.*/Posicao & no ranking de vendas/' > ${WORK_DIR}/pratica_basica/ranking_vendas.txt

# Para testar o 'grep'
cat <<EOF > ${WORK_DIR}/pratica_basica/status_servidores.txt
srv-web-01 ONLINE
srv-web-02 OFFLINE
srv-bd-01 ONLINE
srv-bd-02 ONLINE
srv-cache-01 OFFLINE
EOF

# Para testar o 'cut' (delimitador diferente de espaço)
cat <<EOF > ${WORK_DIR}/pratica_basica/funcionarios.csv
Matricula;Nome;Departamento
101;Ana Silva;TI
102;Bruno Costa;RH
103;Carlos Souza;TI
104;Daniela Lima;Financeiro
EOF

# Para testar 'sort' e 'uniq' (A explicação sobre a dependência entre eles)
cat <<EOF > ${WORK_DIR}/pratica_basica/lista_ips_desordenada.txt
192.168.1.1
10.0.0.50
192.168.1.1
172.16.0.5
10.0.0.50
192.168.1.1
EOF

# ==========================================
# 2. INSTRUÇÕES GERAIS
# ==========================================
echo -e "${YELLOW}[3/5] Gerando arquivos de instrução e dicas para o CTF...${NC}"

cat <<EOF > ${WORK_DIR}/dicas/instrucoes_ctf1.txt
ALERTA DE INCIDENTE INTERNO

Detectamos uma exfiltração de dados. O invasor deixou um rastro pelo sistema, 
mas tentou apagar as provas. Sua missão é rastrear os passos dele e recuperar a FLAG (em base64).

PISTA INICIAL:
O invasor deixou um arquivo oculto na raiz do diretório 'ctf1_sistema'.
Navegue até lá, encontre esse arquivo e leia seu conteúdo para obter a próxima instrução.
EOF

# ==========================================
# 3. CRIANDO CTF 1 (A Trilha de Migalhas)
# ==========================================
echo -e "${YELLOW}[4/5] Construindo o sistema de arquivos do CTF 1 (Trilha e Ruído)...${NC}"

# Criando pastas de ruído
for i in {1..20}; do
    mkdir -p ${WORK_DIR}/ctf1_sistema/pasta_$i
    mkdir -p ${WORK_DIR}/ctf1_sistema/pasta_$i/sub_$(($RANDOM % 100))
done

# PISTA 1: Oculta na raiz
cat <<EOF > ${WORK_DIR}/ctf1_sistema/.pista1_oculta.txt
Boa! Voce encontrou o arquivo oculto.
A proxima pista esta no arquivo 'logs_antigos.txt', localizado na 'pasta_7'.
No entanto, o arquivo esta corrompido e so a LINHA 42 contem a informacao real.
DICA: Voce precisara usar head e tail juntos para extrair APENAS a linha 42.
EOF

# PISTA 2: A linha 42
mkdir -p ${WORK_DIR}/ctf1_sistema/pasta_7
seq 1 100 | sed 's/.*/Linha corrompida de log.../' > ${WORK_DIR}/ctf1_sistema/pasta_7/logs_antigos.txt
sed -i '42s/.*/Acesso confirmado. O invasor registrou seus dados no arquivo "usuarios.csv" na "pasta_12". Voce precisa descobrir o EMAIL dele. Busque pela palavra ADMIN nesse arquivo e extraia apenas a SEGUNDA COLUNA (delimitada por virgula)./' ${WORK_DIR}/ctf1_sistema/pasta_7/logs_antigos.txt

# PISTA 3: O CSV e a extração
mkdir -p ${WORK_DIR}/ctf1_sistema/pasta_12
cat <<EOF > ${WORK_DIR}/ctf1_sistema/pasta_12/usuarios.csv
id,email,perfil,status
1,joao@empresa.com,USER,ativo
2,maria@empresa.com,USER,ativo
3,fantasma@darkweb.net,ADMIN,oculto
4,carlos@empresa.com,USER,inativo
EOF

cat <<EOF >> ${WORK_DIR}/ctf1_sistema/pasta_12/instrucao_extra.txt
Se voce achou o email, use-o para buscar no arquivo 'historico_conexoes.log' (na raiz do ctf1_sistema).
CONTE quantas vezes esse email aparece no log. O NUMERO DE APARICOES eh exatamente 
o NUMERO DE LINHAS do arquivo que esconde a flag final.
EOF

# Gerando o log gigante para o CTF 1
> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log
for i in {1..2000}; do echo "conexao normal de usuario padrao" >> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log; done
for i in {1..333}; do echo "login efetuado por fantasma@darkweb.net as 03:00AM" >> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log; done
for i in {1..1500}; do echo "conexao normal de usuario padrao" >> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log; done

# O ARQUIVO FINAL: Exatamente 333 linhas
ARQUIVO_ALVO="${WORK_DIR}/ctf1_sistema/pasta_14/sub_42/system_config.old"
mkdir -p $(dirname $ARQUIVO_ALVO)
seq 1 332 > $ARQUIVO_ALVO # 332 linhas de lixo
echo "ZmxhZ3t0M3JtMW40bF9yM3MwbHYzX3R1RDB9" >> $ARQUIVO_ALVO # A linha 333 é a flag

# Gerando arquivos de ruído genéricos
for i in {1..150}; do
    LINHAS=$(($RANDOM % 5000 + 1))
    if [ "$LINHAS" -eq 333 ]; then LINHAS=334; fi # Proteção para não haver duas respostas possíveis
    PASTA_DESTINO=${WORK_DIR}/ctf1_sistema/pasta_$(($RANDOM % 20 + 1))
    head -c 500 /dev/urandom | base64 | head -n $LINHAS > ${PASTA_DESTINO}/log_backup_${i}.txt 2>/dev/null
done

# ==========================================
# 4. CRIANDO CTF 2 (Logs de Incidente)
# ==========================================
echo -e "${YELLOW}[5/5] Simulando tráfego do servidor para o CTF 2 (Isso pode levar alguns segundos)...${NC}"

LOG_FILE="${WORK_DIR}/ctf2_logs/access.log"
LINES=75000

# Script awk para geração ultrarrápida do log com injeção de ataque
awk -v lines="$LINES" \
    -v a1="185.15.20.11" -v a2="45.22.19.100" -v a3="103.45.99.12" '
BEGIN {
    srand();
    for(i=1; i<=lines; i++) {
        ip = "172.16." int(rand()*256) "." int(rand()*256);
        status = "200"; method = "GET"; url = "/index.html";
        
        if (i % 11 == 0) { ip = a1; url = "/wp-login.php"; method = "POST"; status = "401"; } 
        else if (i % 23 == 0) { ip = a2; url = "/../../../../etc/shadow"; status = "403"; } 
        else if (i % 37 == 0) { ip = a3; url = "/phpmyadmin/setup.php"; status = "404"; } 
        else if (i % 5 == 0) { url = "/assets/style.css"; } 
        else if (i % 7 == 0) { url = "/images/logo.png"; }
        
        printf "%s - - [29/Apr/2026:16:%02d:%02d +0000] \"%s %s HTTP/1.1\" %s %d\n", \
               ip, int(i/1300)%60, i%60, method, url, status, int(rand()*5000)
    }
}' > $LOG_FILE

echo -e "\n${GREEN}=== AMBIENTE PRONTO ===${NC}"
echo -e "Todos os arquivos foram gerados na pasta: ${BLUE}./${WORK_DIR}${NC}"
echo -e "Use 'cd ${WORK_DIR}/pratica_basica' para começar a demonstração."