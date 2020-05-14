@echo off
REM Script para importacao automatica dos Logs no MySQL
REM Criado por Eduardo Policarpo em 17/12/19
setlocal EnableDelayedExpansion

REM Acessa a unidade Y: que esta mapeada no diretorio de Logs do SRV01 da Genesys srv-outgvprep01
Y:

REM faz a verificacao de quantos arquivos existe na unidade Y: e salva o valor na variavel count_srv01
set count_srv01=0
for %%x in (*) do set /a count_srv01+=1

REM Acessa a unidade Z: que esta mapeada no diretorio de Logs do SRV02 da Genesys srv-outgvprep02
Z:

REM faz a verificacao de quantos arquivos existe na unidade Z: e salva o valor na variavel count_srv02
set count_srv02=0
for %%x in (*) do set /a count_srv02+=1

REM verifica se os valores das variaveis count_srv01 e count_srv02 é maior do que 1 caso verdadeiro é executado o bloco de comandos :SRV01 e/ou :SRV02
REM no diretorio de Logs da genesys sempre existirá um arquivo de Log que fica em execução permanente que é o Log de CALLBACK por isso que a condição para ser verdadeira para haver arquivos para importacao deve ser maior a 1
IF %count_srv01% GTR 1 (GOTO SRV01) ELSE (ECHO Nao existe arquivo para importacao no Servidor srv-outgvprep01)
IF %count_srv02% GTR 1 (GOTO SRV02) ELSE (ECHO Nao existe arquivo para importacao no Servidor srv-outgvprep02)

:SRV01
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
GOTO END

:SRV02
	COPY  \\srv-outgvprep02\ocs_dial_log c:\log_genesys\processados
	REM o comando abaixo pega o nome do arquivo e salva no arquivo temp.txt
	dir \\srv-outgvprep02\ocs_dial_log /b/o:n > C:\log_genesys\temp.txt
	REM cria a variavel nomeArquivo e atribui o conteudo do arquivo temp.txt a variavel
	SET /p nomeArquivo=<C:\log_genesys\temp.txt
	REM salva um historico de importacao pegando o nome do aquivo a data e hora 
	echo !nomeArquivo! importado para o BD em %DATE% %TIME% >> c:\log_genesys\historico-de-importacoes.txt
	REM renomeia o arquivo para o nome da tabela onde serão importados os dados , para que o mysqlimport funcione o arquivo tem que estar com o nome da tabela
	RENAME \\srv-outgvprep02\ocs_dial_log\*.rep log_genesys.txt
	REM faz a importação no banco, atenção a ordem das colunas no arquivo com o comando 
	mysqlimport -v --columns="tempo,action,record_handle,list_id,campaign_id,group_id,ocs_app_id,tenant_id,connection_id,dn,record_id,phone,phone_type,record_type,record_status,call_result,attempt,dial_sched_time,call_time,daily_from,daily_till,tz_dbid,tz_offset,agent_id,chain_id,chain_n,v_ocs_numero_protocolo,v_ocs_cod_cliente,v_ocs_nome_cliente,v_ocs_cpf_cnpj,v_url_crm" --lines-terminated-by="\r\n" --fields-terminated-by="|" --local -u root -p#plmrrpv#2101 genesys \\\srv-outgvprep02\\ocs_dial_log\\log_genesys.txt
	DEL /Q \\srv-outgvprep02\ocs_dial_log\log_genesys.txt
	DEL /Q C:\log_genesys\temp.txt
GOTO END

:END

endlocal
