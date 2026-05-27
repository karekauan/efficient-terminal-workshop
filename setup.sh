#!/bin/bash

# Cores para o output do terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Iniciando a preparação do ambiente para o Workshop...${NC}\n"

WORK_DIR="workshop_terminal"
echo -e "${YELLOW}[1/6] Criando diretórios base em ./${WORK_DIR}...${NC}"
mkdir -p ${WORK_DIR}/{pratica_basica,ctf1_sistema,ctf2_logs,dicas}
mkdir -p ${WORK_DIR}/pratica_final/{imagens_duplicadas,espaco_disco}

# ==========================================
# 1. CRIANDO ARQUIVOS PARA PRÁTICA BÁSICA
# ==========================================
echo -e "${YELLOW}[2/6] Gerando arquivos curtos para treino de comandos básicos...${NC}"

cat <<EOF > ${WORK_DIR}/pratica_basica/poema.txt
Batatinha quando nasce
Espalha a rama pelo chao
A menina quando dorme
Poe a mao no coracao
EOF

seq 1 30 | sed 's/.*/Posicao & no ranking de vendas/' > ${WORK_DIR}/pratica_basica/ranking_vendas.txt

cat <<EOF > ${WORK_DIR}/pratica_basica/status_servidores.txt
srv-web-01 ONLINE
srv-web-02 OFFLINE
srv-bd-01 ONLINE
srv-bd-02 ONLINE
srv-cache-01 OFFLINE
EOF

cat <<EOF > ${WORK_DIR}/pratica_basica/funcionarios.csv
Matricula;Nome;Departamento
101;Ana Silva;TI
102;Bruno Costa;RH
103;Carlos Souza;TI
104;Daniela Lima;Financeiro
EOF

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
echo -e "${YELLOW}[3/6] Gerando arquivos de instrução e dicas para o CTF...${NC}"

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
echo -e "${YELLOW}[4/6] Construindo o sistema de arquivos do CTF 1 (Trilha e Ruído)...${NC}"

for i in {1..20}; do
    mkdir -p ${WORK_DIR}/ctf1_sistema/pasta_$i
    mkdir -p ${WORK_DIR}/ctf1_sistema/pasta_$i/sub_$(($RANDOM % 100))
done

cat <<EOF > ${WORK_DIR}/ctf1_sistema/.pista1_oculta.txt
Boa! Voce encontrou o arquivo oculto.
A proxima pista esta no arquivo 'logs_antigos.txt', localizado na 'pasta_7'.
No entanto, o arquivo esta corrompido e so a LINHA 42 contem a informacao real.
EOF

mkdir -p ${WORK_DIR}/ctf1_sistema/pasta_7
seq 1 100 | sed 's/.*/Linha corrompida de log.../' > ${WORK_DIR}/ctf1_sistema/pasta_7/logs_antigos.txt
sed -i '42s/.*/Acesso confirmado. O invasor registrou seus dados no arquivo "usuarios.csv" na "pasta_12". Voce precisa descobrir o EMAIL dele. Busque pela palavra ADMIN nesse arquivo e extraia apenas a SEGUNDA COLUNA (delimitada por virgula)./' ${WORK_DIR}/ctf1_sistema/pasta_7/logs_antigos.txt

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

> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log
for i in {1..2000}; do echo "conexao normal de usuario padrao" >> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log; done
for i in {1..333}; do echo "login efetuado por fantasma@darkweb.net as 03:00AM" >> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log; done
for i in {1..1500}; do echo "conexao normal de usuario padrao" >> ${WORK_DIR}/ctf1_sistema/historico_conexoes.log; done

ARQUIVO_ALVO="${WORK_DIR}/ctf1_sistema/pasta_14/sub_42/system_config.old"
mkdir -p $(dirname $ARQUIVO_ALVO)
seq 1 332 > $ARQUIVO_ALVO
echo "ZmxhZ3t0M3JtMW40bF9yM3MwbHYzX3R1RDB9" >> $ARQUIVO_ALVO

for i in {1..150}; do
    LINHAS=$(($RANDOM % 5000 + 1))
    if [ "$LINHAS" -eq 333 ]; then LINHAS=334; fi
    PASTA_DESTINO=${WORK_DIR}/ctf1_sistema/pasta_$(($RANDOM % 20 + 1))
    head -c 500 /dev/urandom | base64 | head -n $LINHAS > ${PASTA_DESTINO}/log_backup_${i}.txt 2>/dev/null
done

# ==========================================
# 4. CRIANDO CTF 2 (Logs de Incidente)
# ==========================================
echo -e "${YELLOW}[5/6] Simulando tráfego do servidor para o CTF 2...${NC}"

LOG_FILE="${WORK_DIR}/ctf2_logs/access.log"
LINES=75000

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

# ==========================================
# 5. CRIANDO ARQUIVOS PARA PRÁTICA FINAL (Truques)
# ==========================================
echo -e "${YELLOW}[6/6] Preparando ambiente para os truques de produtividade finais...${NC}"

# --- Setup para o md5sum (Clones) ---
DIR_IMAGENS="${WORK_DIR}/pratica_final/imagens_duplicadas"
# Clone 1 (Praia)
echo "CONTEUDO_FALSO_DE_IMAGEM_DA_PRAIA" > ${DIR_IMAGENS}/foto_praia.jpg
echo "CONTEUDO_FALSO_DE_IMAGEM_DA_PRAIA" > ${DIR_IMAGENS}/copia_praia.jpg
echo "CONTEUDO_FALSO_DE_IMAGEM_DA_PRAIA" > ${DIR_IMAGENS}/backup_img_12.jpg

# Clone 2 (Montanha)
echo "CONTEUDO_FALSO_DA_MONTANHA" > ${DIR_IMAGENS}/montanha.jpg
echo "CONTEUDO_FALSO_DA_MONTANHA" > ${DIR_IMAGENS}/img_001_final.jpg

# Arquivo Único (Gato)
echo "CONTEUDO_FALSO_DO_GATO_EXCLUSIVO" > ${DIR_IMAGENS}/gato.png

# --- Setup para o du -sh (Tamanhos diferentes) ---
# Usamos o comando 'dd' com '/dev/zero' para criar arquivos que realmente
# ocupam espaço no disco de forma muito rápida.
DIR_ESPACO="${WORK_DIR}/pratica_final/espaco_disco"
dd if=/dev/zero of=${DIR_ESPACO}/backup_banco.sql bs=1M count=120 2>/dev/null
dd if=/dev/zero of=${DIR_ESPACO}/video_treinamento.mp4 bs=1M count=55 2>/dev/null
dd if=/dev/zero of=${DIR_ESPACO}/relatorio_antigo.pdf bs=1M count=12 2>/dev/null
dd if=/dev/zero of=${DIR_ESPACO}/planilha_custos.xlsx bs=1M count=2 2>/dev/null

echo -e "\n${GREEN}=== AMBIENTE PRONTO ===${NC}"
echo -e "Todos os arquivos foram gerados na pasta: ${BLUE}./${WORK_DIR}${NC}"
echo -e "Use 'cd ${WORK_DIR}/pratica_basica' para começar a demonstração inicial."