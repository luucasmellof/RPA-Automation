Requisitos
==========
Para esse projeto é necessário instalar:
	- Python versão 3.+
	- RobotFramework:
		Library     SeleniumLibrary
		Library     CSVLibrary
		Library     OperatingSystem
		Library     String
		Library     DateTime
Ter um arquivo CSV chamado "LOCALIDADES.csv" no diretório c:/temp (Pode ser mudado nas variáveis no arquivo resources.robot)
O arquvio Localidades precisa conter as informações conforme o arquivo padrão posteriormente disponibilizado


Para executar
=============
Com o projeto aberto em uma IDE:
	- Digitar no terminal: robot CNES_RPA.robot
Rodar pelo cmd:
	- Abrir o terminal windows (cmd)
	- Digitar o comando: cd <pasta onde está o arquivo>
	- Digitar o comando: robot CNES_RPA.robot
Os arquivos PDF serão salvos em uma estrutura de diretórios seguindo o seguinte padrão: C:/temp/Download PDF/<Estado>/<Cidade>/<NUM_CNES>.pdf
O arquivo CSV contendo os registros pesquisados será salvo na pasta: C:/temp/Download PDF/<Ano>-<Mes>-<Dia>-<Hora>h-<Minuto>m_export.csv

Decisões tomadas
================
- Foi implementado para que o robô busque pelas 5 primeiras páginas conforme a requisição bônus.
- O RPA está baixando o PDF lendo diretamente a tabela, sem precisar fazer a pesquisa novamente, achei que seria mais performático.
- Foram adicionados poucos "Sleeps" principalmente por conta do download do PDF, por conta de que não há mensagem de sucesso para o download. Além disso a barra de download sai da tela antes dele finalizar.
