# Configuração do Ambiente Python (no arch)

## 1. Instalação do Python e do PIP

No Arch Linux, instale o Python e o gerenciador de pacotes PIP utilizando o `pacman`:
```bash
sudo pacman -Syu python python-pip
```

Verifique se a instalação foi realizada corretamente:
```bash
python --version
python -m pip --version
```

## 2. Criando o ambiente virtual
Entre no diretório do projeto:

```bash
cd edutrack-ai
```

Crie um ambiente virtual chamado `.venv`:
```bash
python -m venv .venv
```

O ambiente virtual permite instalar bibliotecas específicas do projeto sem modificar os pacotes Python gerenciados pelo sistema operacional.

## 3. Ativando o ambiente virtual

Execute o comando:
```bash
source .venv/bin/activate
```

Após a ativação, o terminal deverá apresentar algo semelhante a:
```text
(.venv) pc@SODaLG edutrack-ai
```

Com o ambiente ativo, os comandos Python e PIP utilizarão as instalações desse ambiente.

## 4. Instalando as dependências

Primeiro, atualize o PIP:
```bash
python -m pip install --upgrade pip
```

Em seguida, instale as bibliotecas necessárias para o projeto:
```bash
python -m pip install streamlit requests pandas watchdog
```

### Utilizando o `requirements.txt`

Para manter as dependências documentadas e facilitar a configuração em outras máquinas, recomenda-se utilizar o arquivo `requirements.txt`.

Exemplo de conteúdo:
```text
streamlit
requests
pandas
watchdog
```

Para instalar todas as dependências listadas no arquivo, execute:
```bash
python -m pip install -r requirements.txt
```

**Importante:** execute os comandos de instalação com o ambiente virtual ativado.

## 5. Executando o projeto
Com as dependências instaladas, execute a aplicação:
```bash
python -m streamlit run app.py
```

Após a inicialização, o Streamlit disponibilizará um endereço local, geralmente:

```text
http://localhost:8501
```

Acesse esse endereço no navegador para visualizar a aplicação.

Para encerrar a execução, pressione `Ctrl + C` no terminal.

## 6. Desativando o ambiente virtual
Quando terminar de trabalhar no projeto, você poderá desativar o ambiente virtual com:
```bash
deactivate
```

Para trabalhar novamente, entre no diretório do projeto e ative o ambiente:
```bash
cd edutrack-ai
source .venv/bin/activate
```

## 7. Configuração do `.gitignore`
O ambiente virtual não deve ser enviado ao repositório Git. Adicione as seguintes entradas ao arquivo `.gitignore`:
```gitignore
# Ambiente virtual Python
.venv/
venv/

# Cache Python
__pycache__/
*.py[cod]

# Arquivos de configuração locais
.env

# Configurações de editores
.vscode/
.idea/
```

O arquivo `requirements.txt` deve ser versionado, pois permite que outros desenvolvedores instalem as dependências necessárias para executar o projeto.

## Resumo dos comandos
Após instalar Python e PIP, a configuração inicial pode ser realizada com:

```bash
cd edutrack-ai

python -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip
python -m pip install -r requirements.txt

python -m streamlit run app.py
```
