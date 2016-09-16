# Script para se proteger de Ransomware
Não é garantido que a triagem e o script vão proteger efetivamente contra ransomware, mas é uma forma de bloquear o acesso do usuário que por ventura tentar salvar um arquivo no servidor com uma extensão que geralmente pertence aos ransomwares.
Lembre-se de fazer backup constantemente, manter seu sistema operacional e antivírus sempre atualizados, e nunca clique em arquivos ou links suspeitos.

### Criar um Bot no Telegram

```
Adicionar o usuário @BotFather para a sua conta do telegram ou acessar o endereço https://telegram.me/BotFather
e seguir os passos abaixo:
- /newbot - criar um novo bot
- Digitar um nome para o bot. Exemplo: Teste123 Bot
- Digitar um nome de uusário para o bot. Precisar terminar com 'bot' Exemplo: (test123_bot)

Anotar a chave da API (API KEY):
1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U

Substituir na url com a chave da API
https://api.telegram.org/bot${API_KEY}/getUpdates
https://api.telegram.org/bot1234567890:AAFd2sDMplKGyoajsPWARnSOwa9EqHiy17U/getUpdates

Abrir o browser e colar a URL. Você vai receber uma saída no formato JSON, pegar o valor do 'id'.

{"ok":true,"result":[{"update_id":565543449,
"message":{"message_id":3,"from":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someusername"},"chat":{"id":123456789,"first_name":"Some Name","last_name":"Some Last Name",
"username":"someuser","type":"private"},"date":1472165730,"text":"hello"}}]}
```
