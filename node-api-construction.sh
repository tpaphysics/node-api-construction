#!/bin/bash

if [ -z $1 ]; then
  echo 'Digite: ./api-node-construction.sh nomeDoSeuProjeto
  exit 1
fi

mkdir ./$1

cd ./$1

git init

cat <<EOF >.gitignore
node_modules
dist
.env
EOF 

# Configurações para padronização do código

yarn init -y

yarn add typescript @types/node ts-node-dev git-commit-msg-linter -D


cat <<EOF > tsconfig.json 
{
  "compilerOptions": {
    "target": "es2019",                                 
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./dist",                               
    "esModuleInterop": true,                            
    "forceConsistentCasingInFileNames": true,           
    "strict": true,                                     
    "skipLibCheck": true                                 
  }
}
EOF

cat <<EOF >.editorconfig
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
EOF

yarn add eslint prettier eslint-config-airbnb-typescript-prettier -D

sed -i '/license/a \  "scripts": { "dev:server":"ts-node-dev --exit-child --inspect --ignore-watch --transpile-only src/server.ts", "build": "tsc" },' package.json

yarn

cat <<EOF >.eslintrc.js
module.exports = {
  extends: 'airbnb-typescript-prettier',
  rules: {
    'class-methods-use-this': 'off',
  },
};

cat <<EOF > .eslintignore
node_modules
dist
EOF

cat <<EOF >prettier.config.js
module.exports = {
  singleQuote: true,
  trailingComma: 'all',
  arrowParens: 'avoid',
};
EOF

## Intalação do express e separação básica de controllers e serviços ...

mkdir ./src

yarn add express
yarn add @types/express -D
yarn add dotenv

cat <<EOF >./src/server.ts
import express from 'express';
import route from './routes/routes';
import 'dotenv/config';

const app = express();

app.use(express.json());

app.use(route);
app.listen(process.env.SERVER_PORT || 4000, () => {
  console.clear();
  console.log('[*] api -> http://localhost:4000/route\n\n[*] prisma studio -> http://localhost:5000')
});
EOF

mkdir ./src/routes

cat <<EOF >./src/routes/routes.ts
import { Router } from 'express';
import SendMessageController from '../controllers/SendMessageController';

const route = Router();

route.get('/route', new SendMessageController().handle);

export default route;
EOF

mkdir ./src/services

cat <<EOF >./src/services/SendMessageService.ts
type ResponseMessage = {
  message: string;
};

class SendMessageService {
  public async execute(msg: string): Promise<ResponseMessage> {
    const resp = {
      message: msg,
    };
    return resp;
  }
}

export default SendMessageService;
EOF

mkdir ./src/controllers

cat <<EOF >./src/controllers/SendMessageController.ts
import { Response } from 'express';
import SendMessageService from '../services/SendMessageService';

type RequestSendMessage = {
  body: {
    message: string;
  };
};

class SendMessageController {
  async handle(req: RequestSendMessage, res: Response) {
    const { message } = req.body;

    const service = new SendMessageService();

    const result = await service.execute(message);

    return res.json(result);
  }
}

export default SendMessageController;
EOF

# Intalação do prisma e definindo o sqlite como banco de desenvolvimento

yarn add prisma
yarn add @types/prisma -D
yarn prisma init --datasource-provider sqlite

code .
