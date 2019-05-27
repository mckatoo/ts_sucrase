#!/bin/bash

PROJETO=$1
if [ -z "$PROJETO" ]
then
  while [ -z "$PROJETO" ]
  do
    echo "Informe um nome para o projeto:"
    read -r "PROJETO"
  done
fi

mkdir "$PROJETO"
cd "$PROJETO" || exit

# Constroi o package.json sem perguntar parametros, para usar parametros é só tirar o "-y"
yarn init -y

# Instalar modulos em ambiente de desenvolvimento
# typescript é o modulo para node responsavel para tipagem do javascript
# sucrase é responsavel por converter o typescript em javascript porque o browser ou o node não lê arquivo ts e sim js
# nodemon é o módulo responsável por executar o app e monitorar as mudanças reiniciando se necessário
# eslint e módulos relacionados ajudam a identificar erros em tempo de desenvolvimento
yarn add -D typescript sucrase nodemon eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Cria o diretório onde ficaram os codigos-fontes do projeto
mkdir src

# Cria o primeiro arquivo para iniciar o projeto
touch src/server.ts

# Insere no arquivo package.json após a linha de license dois scripts, um para iniciar o app em modo desenvolvimento e outro para build
sed -i '/"license": "MIT",/a   "scripts": { "dev": "nodemon src/server.ts", "build": "sucrase ./src -d ./dist --transforms typescript,imports" },' package.json

# Cria e preenche o arquivo de configuração do nodemon
touch nodemon.json
echo '{"watch": ["src"], "ext": "ts", "execMap": {"ts": "sucrase-node src/server.ts"}}' > nodemon.json

# Configura o eslint, remove o package-lock.json que é usado pelo npm e instala as dependências com o yarn já que estamos usando o yarn e não o npm
yarn eslint --init && rm package-lock.json && yarn

# Insere configuração de parser ao eslint
sed -i "/module.exports = {/a   parser: '@typescript-eslint/parser'," .eslintrc.js
sed -i "/'extends':/i   plugins: \['@typescript-eslint'\]," .eslintrc.js
sed -i "/plugins: \['@typescript-eslint'\],/a  extends: \['plugin:@typescript-eslint/recommended','standard'\]," .eslintrc.js
sed -i "/'extends': 'standard'/d" .eslintrc.js
