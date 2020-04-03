REM Script para importação automatica dos Logs no MySQL
REM Criado por Eduardo Policarpo em 17/12/19
@echo off
setlocal EnableDelayedExpansion
color 1F
title Importacao de Dados para MySQL
if exist  \\srv-outgvprep01\ocs_dial_log\*.rep (
	COPY  \\srv-outgvprep01\ocs_dial_log c:\log_genesys\processados
	REM o comando abaixo pega o nome do arquivo e salva no arquivo temp.txt
	dir \\srv-outgvprep01\ocs_dial_log /b/o:n > C:\log_genesys\temp.txt
	REM cria a variavel nomeArquivo e atribui o conteudo do arquivo temp.txt a variavel
	SET /p nomeArquivo=<C:\log_genesys\temp.txt
	REM salva um historico de importacao pegando o nome do aquivo a data e hora 
	echo !nomeArquivo! importado para o BD em %DATE% %TIME% >> c:\log_genesys\historico-de-importacoes.txt
	REM renomeia o arquivo para o nome da tabela onde serão importados os dados , para que o mysqlimport funcione o arquivo tem que estar com o nome da tabela
	RENAME \\srv-outgvprep01\ocs_dial_log\*.rep log_genesys.txt
	REM faz a importação no banco, atenção a ordem das colunas no arquivo com o comando 
	mysqlimport -v --columns="tempo,action,record_handle,list_id,campaign_id,group_id,ocs_app_id,tenant_id,connection_id,dn,record_id,phone,phone_type,record_type,record_status,call_result,attempt,dial_sched_time,call_time,daily_from,daily_till,tz_dbid,tz_offset,agent_id,chain_id,chain_n,v_ocs_numero_protocolo,v_ocs_cod_cliente,v_ocs_nome_cliente,v_ocs_cpf_cnpj,v_url_crm" --lines-terminated-by="\r\n" --fields-terminated-by="|" --local -u root -p#plmrrpv#2101 genesys \\\srv-outgvprep01\\ocs_dial_log\\log_genesys.txt
	DEL /Q \\srv-outgvprep01\ocs_dial_log\log_genesys.txt
	DEL /Q C:\log_genesys\temp.txt
) else (
    echo Nao existe arquivo para importacao
)

