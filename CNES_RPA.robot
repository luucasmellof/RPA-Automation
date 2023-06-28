*** Settings ***
Documentation    Teste Tecnico RobotFramework
Resource         resources/resources.robot

*** Tasks ***
Passo 1: buscar e validar arquivo CSV
    Verificar se o arquivo de input existe     # Se o arquivo não existe a execução será abortada
    Zerar Arquivo De Exportação A Cada Execução
    Tratar Arquivo CSV

Passo 2: abrir site e inserir dados extraídos
    Abrir site CNES
    @{dict_receive}=    Read Csv File To List    ${csv_file}
    FOR     ${line_to_read}    IN  @{dict_receive}
        IF  "${line_to_read}[0]" != "UF"
            Ler CSV E Inserir Dados No Site    ${line_to_read}
            Clicar No Botão Pesquisar
            Exportar dados para as 5 primeiras páginas
        END
    END
    Salvar arquivo de exportação no diretório padrão da execução
    Fechar Navegador
