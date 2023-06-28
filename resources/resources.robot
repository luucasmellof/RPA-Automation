*** Settings ***
Library     SeleniumLibrary
Library     CSVLibrary
Library     OperatingSystem
Library     String
Library     DateTime

*** Variables ***
${csv_file}             c:/temp/LOCALIDADES.csv
${csv_file_export}      c:/temp/export.csv
${url}                  https://cnes.datasus.gov.br/pages/estabelecimentos/consulta.jsp
${browser}              chrome
${pdf_dir}              C:/Users/Lucas/Downloads/fichaCompletaEstabelecimento.pdf
${folder_exec}          C:/temp/Download PDF
${search_button}        xpath=/html/body/div[2]/main/div/div[2]/div/form[2]/div/button

*** Keywords ***
Verificar se o arquivo de input existe
    File Should Exist           ${csv_file}
    File Should Not Be Empty    ${csv_file}

Zerar arquivo de exportação a cada execução
    Empty Csv File    ${csv_file_export}

Salvar arquivo de exportação no diretório padrão da execução
    ${date}=    Get Current Date    result_format=%Y-%m-%d-%Hh-%Mm
    Move File    ${csv_file_export}     ${folder_exec}/${date}_export.csv

Abrir Site CNES
    Open Browser    ${url}  ${browser}
    Maximize Browser Window

Fechar Navegador
    Close Browser

Verificar se os campos carregaram
    Wait Until Page Contains Element    xpath=/html/body/div[2]/main/div/div[2]/div/form[1]/div[2]/div[1]/div/select

Inserir dado Estado via CSV
    [Arguments]    ${estado_select}
    TRY
        Wait Until Page Contains Element    xpath=/html/body/div[2]/main/div/div[2]/div/form[1]/div[2]/div[1]/div/select     5
        Select From List By Label  xpath=/html/body/div[2]/main/div/div[2]/div/form[1]/div[2]/div[1]/div/select    ${estado_select}
    EXCEPT
        Log To Console    Não foi possível adicionar o dado Estado ao CSV
    END

Inserir dado Município via CSV
    [Arguments]    ${municipio_select}
    TRY
        Wait Until Element Is Enabled    xpath=/html/body/div[2]/main/div/div[2]/div/form[1]/div[2]/div[2]/div/select     5
        Select From List By Label   xpath=/html/body/div[2]/main/div/div[2]/div/form[1]/div[2]/div[2]/div/select   ${municipio_select}
    EXCEPT
        Log To Console   Não foi possível adicionar dado Município ao CSV
    END

Ler CSV e inserir dados no site
    [Arguments]    ${line_to_read}
    TRY
        ${json}=                Get file  resources/estados.json
        ${object}=              Evaluate    json.loads('''${json}''')   json
        ${municipio_csv}        Set Variable    ${line_to_read}[1]
        ${municipio_tratado}    Convert To Upper Case    ${municipio_csv}
        ${estado_tratado}       Set Variable    ${object["${line_to_read}[0]"]}
        Inserir Dado Estado Via CSV    ${estado_tratado}
        Sleep    1
        Inserir Dado Município Via CSV    ${municipio_tratado}
        Sleep    1
        Log To Console    \n Processando dados para o estado ${estado_tratado} e o municipio ${municipio_tratado}.
    EXCEPT
        Log To Console    Não foi possível Inserir dados no Site
    END

Clicar no botão pesquisar
    TRY
        Wait Until Element Is Enabled    ${search_button}     3
        Click Button                     ${search_button}
        Sleep    0.7    #Mesmo aparecendo em tela os paths não contém informações, precisa de um tempo para aparecer
    EXCEPT
        Log To Console    Não foi possível clicar no botão pesquisar
    END

Exportar dados para as 5 primeiras páginas
    Sleep    1
    ${index}            Set Variable    0
    ${count}            Set Variable    0
    ${element_exists}   Set Variable    True
    WHILE    ${element_exists} == True
        ${index}    Evaluate    ${index} + 1    #Adiciona 1 no index do XPath até não existir
        ${element_exists}=          Run Keyword And Return Status   Page Should Contain Element    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/div/div/div/ul/li[${index}]/a
        Exit For Loop If    ${element_exists} == False
        ${count}    Evaluate    ${count} + 1    #Contagem de quantas janelas existem para pesquisa
    END
    IF    ${count} >= 7
        FOR    ${table_index}    IN RANGE    2    7
            Run Keyword If    ${table_index} >= 3   Click Element    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/div/div/div/ul/li[${table_index}]/a
            Wait Until Page Contains Element   xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[1]/td[1]     5
            Exportar Dados Da Tabela
        END
    ELSE IF    ${count} == 0
        Wait Until Page Contains Element   xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[1]/td[1]     5
        Exportar Dados Da Tabela
        Log To Console    Não há mais páginas para buscar
    ELSE
        FOR    ${table_index}    IN RANGE    2   ${count}
            Run Keyword If    ${table_index} >= 3   Click Element    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/div/div/div/ul/li[${table_index}]/a
            Wait Until Page Contains Element   xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[1]/td[1]     5
            Exportar Dados Da Tabela
        END
    END

Exportar dados da tabela
    TRY
        Sleep    2  #Mesmo aparecendo em tela os paths não contém informações, precisa de um tempo para aparecer
        Wait Until Page Contains Element   xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[1]/td[1]     5
        #Validar se o arquivo export Existe e criar caso não exista
        ${file_exists}    Run Keyword And Return Status    File Should Not Exist    ${csv_file_export}
        Run Keyword If    ${file_exists}    Empty Csv File    ${csv_file_export}    # Ação quando o arquivo existe

        FOR    ${linha}    IN RANGE    1    11
            FOR    ${coluna}   IN RANGE    1   8
                ${element_exists}=          Run Keyword And Return Status   Page Should Contain Element    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[${linha}]/td[${coluna}]
                Exit For Loop If    ${element_exists} == False
                ${cel_value}=   Get Text    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[${linha}]/td[${coluna}]
                ${cel_convert}=  Convert To String    ${cel_value};
                Append To File    ${csv_file_export}    ${cel_convert}
            END
            ${element_exists}=          Run Keyword And Return Status   Page Should Contain Element    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[${linha}]/td[1]
            Exit For Loop If    ${element_exists} == False
            Append To File    ${csv_file_export}    \n      #Quebra de linha após o preenchimento das informações da linha da tabela
        END
        Log To Console      Exportou os dados da tabela e importou no CSV. Iniciando Download do PDF para a aba selecionada.
        Exportar PDF De Cada Unidade
    EXCEPT
        Log To Console    Não foi possível extrair os dados da tabela
    END

Exportar PDF de cada unidade
    TRY
        FOR    ${linha}   IN RANGE    1   11
            #   Aguarda primeira linha aparecer
            Wait Until Page Contains Element    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[1]/td[8]/a     5

            #   Valida se ainda existe arquivos pra baixar
            ${element_exists}=          Run Keyword And Return Status   Page Should Contain Element    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[${linha}]/td[8]/a
            Exit For Loop If    ${element_exists} == False

            #   CLICA NO BOTÃO PARA ABRIR NOVA JANELA COM INFORMAÇÕES
            ${botao}=    Get WebElement    xpath=/html/body/div[2]/main/div/div[2]/div/div[3]/table/tbody/tr[${linha}]/td[8]/a
            ${link}=    Get Element Attribute    ${botao}    href
            Open Browser    ${link}     chrome  #Abre nova janela com informações
            Wait Until Element Is Visible    id=cnes     5
            ${cnes_num}=    Get Value     id=cnes     #Buscar o CNES que será impresso
            ${estado}=      Get Value    xpath=/html/body/div[2]/main/div/div[3]/div[1]/div/section/div[3]/div/div[2]/div[1]/div/form/div[4]/div[3]/div/input
            ${municipio}=   Get Value    xpath=/html/body/div[2]/main/div/div[3]/div[1]/div/section/div[3]/div/div[2]/div[1]/div/form/div[4]/div[2]/div/input
            ${dir_export}   Set Variable    C:/temp/Download PDF/${estado}/${municipio}/${cnes_num}.pdf
            Click Element   xpath=/html/body/div[2]/main/div/div[3]/div[1]/header/nav/div/a     #Clica no botão de impressão
            Wait Until Page Contains Element    xpath=/html/body/div[2]/main/div/div[3]/div[3]/div/div/div/div/div[1]/div[2]/form/div/div[1]/div[1]/div/div/label/input    10
            Sleep    0.8        #O checkbox aparece na tela mas ainda não é clicável, precisa de um tempo para se tornar clicável
            Select Checkbox     xpath=/html/body/div[2]/main/div/div[3]/div[3]/div/div/div/div/div[1]/div[2]/form/div/div[1]/div[1]/div/div/label/input     #Clica no checkbox "Ficha completa"
            Click Button        xpath=/html/body/div[2]/main/div/div[3]/div[3]/div/div/div/div/div[2]/button[1]     #Clica no botão de impressão
            Wait Until Element Is Not Visible    xpath=/html/body/div[2]/main/div/div[3]/div[1]/div/section/div[2]/div/span     #Aguarda o ícone de carregamento sair da tela para sinalizar que download finalizou
            Sleep    1.5        #O ícone sai da tela um pouco antes do download finalizar, precisa de um tempo para o navegador salvar o arquivo
            Close Browser
            File Should Exist    ${pdf_dir}
            Move File   ${pdf_dir}   ${dir_export}  #Move os arquivos para a pasta padrão e renomeia
            Switch Browser    1
        END
    EXCEPT
        Log To Console    Não foi possível fazer o download do arquivo
    END

