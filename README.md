# API de Autenticação e Autorização JWT (AV2)

Este projeto faz parte da AV2, focado na implementação de autenticação JWT, segurança, testes, monitoramento e deploy da API.

## 📦 1. Dependências do Projeto
O projeto utiliza as seguintes bibliotecas essenciais para Spring Boot 3.x:
- **Spring Boot Starter Web** – Construção de APIs RESTful
- **Spring Boot Starter Security** – Autenticação e autorização
- **Spring Boot Starter OAuth2 Resource Server** – Validação de tokens JWT
- **Spring Boot Starter Data JPA** – Persistência de dados
- **H2 Database** – Banco de dados em memória para testes
- **Springdoc OpenAPI** – Geração automática da documentação via Swagger UI
- **Spring Boot DevTools** – Ferramentas para desenvolvimento ágil
- **Lombok** – Redução de código repetitivo
- **Spring Boot Starter Test** – JUnit 5 e Mockito para testes unitários
- **Spring Boot Actuator** – Monitoramento e métricas da API
- **Prometheus** – Coleta de métricas de uso da API em tempo real

## ⚙️ 2. Configuração do Ambiente
As propriedades essenciais estão definidas no arquivo `application.yml`:
- Configuração do banco de dados H2
- Configuração do Spring Security e chave JWT
- Ativação do Spring Boot Actuator para expor métricas

## 🛡️ 3. Implementação da API de Autenticação
- Endpoints `/auth/login` e `/auth/register` para autenticação e registro
- Geração e validação de JWT
- Spring Security aplicado para proteger recursos

## 🔑 4. Aplicação da Autenticação JWT nos Endpoints CRUD
- Endpoints CRUD protegidos por autenticação JWT
- Operações restritas para usuários logados e administradores
- Integração modular simulando arquitetura realista

## ✅ 5. Testes com JUnit
- Testes unitários para autenticação
- Mockito utilizado para mockar serviços

## 📈 6. Testes de Carga com JMeter
- Arquivo de teste JMeter incluso
- Simulação de login e análise de métricas como throughput, tempo médio de resposta e erro %

---

## 🧪 Testes com Apache JMeter

Esta API foi testada com o Apache JMeter para simular requisições de registro e login de usuários, além de carga nos endpoints protegidos.

### Como configurar o JMeter para testar a API:
1. Abra o JMeter e crie um novo Test Plan.
2. Adicione um **Thread Group**.
3. Adicione um **HTTP Header Manager** ao Thread Group e configure:
   - `Content-Type: application/json`
4. Adicione um **HTTP Request**:
   - **Protocol:** `https`
   - **Server Name or IP:** `prova-av2.onrender.com`
   - **Path:** `/auth/register` (ou `/auth/login`)
   - **Method:** `POST`
   - **Body Data:**
     ```json
     {
       "username": "usuario1",
       "password": "senha123",
       "role": "USER"
     }
     ```
5. Execute o teste e analise os resultados no **Summary Report** ou **View Results Tree**.

![Screenshot_1](https://github.com/user-attachments/assets/c4d9ed24-856c-4b9f-821d-831139ba9f74)
![Screenshot_2](https://github.com/user-attachments/assets/948746da-84bf-4fef-924b-ea3f0e72f539)

---


## 📖 7. Documentação com Swagger / OpenAPI
- Documentação automática gerada pelo Springdoc OpenAPI
- Endpoints expostos via Swagger UI
![Screenshot_3](https://github.com/user-attachments/assets/71fb67cb-58cd-4a87-9ced-1a7420996cd1)


## 🩺 8. Monitoramento da API
- Spring Boot Actuator configurado
- Prometheus configurado para coleta de métricas
- Grafana com dashboards para monitoramento

### Exemplo de Dashboard no Grafana
![grafana-dashboard](https://github.com/user-attachments/assets/6a618b7f-1538-4aa8-9d08-a77987cc4555)

### Exemplo de Métricas no Prometheus
![prometheus-dashboard](https://github.com/user-attachments/assets/5c45bde3-8f55-43d5-ba70-99a60b248554)


## 🚚 9. Deploy do Projeto
- Containerização com Docker (Dockerfile incluso)
- Deploy realizado na plataforma gratuita [Render](https://render.com/)
- Código-fonte versionado no GitHub

---

## 🚀 Como Usar a API

### **Atenção:**
- **Não acesse os endpoints diretamente pelo navegador** (ex: `/auth/register`, `/auth/login`, `/`). Isso resultará em **acesso negado (HTTP 403)**, pois são endpoints POST e protegidos.
- **Endpoints abertos para uso:**
  - [https://av2-96x7.onrender.com/actuator/health](https://av2-96x7.onrender.com/actuator/health) — Verifica o status da aplicação
  - [https://av2-96x7.onrender.com/swagger-ui/index.html](https://av2-96x7.onrender.com/swagger-ui/index.html) — Interface Swagger para testar e documentar a API

### **Como registrar e logar:**
1. Acesse o Swagger UI: [https://av2-96x7.onrender.com/swagger-ui/index.html](https://av2-96x7.onrender.com/swagger-ui/index.html)
2. Expanda o endpoint `/auth/register` e clique em **Try it out**
3. Preencha o corpo da requisição, por exemplo:
   ```json
   {
     "username": "usuario1",
     "password": "senha123",
     "role": "USER"
   }
   ```
4. Clique em **Execute** para registrar
5. Faça login em `/auth/login` com o mesmo usuário e senha para obter o token JWT
6. Clique em **Authorize** no topo do Swagger UI e cole o token JWT para acessar os endpoints protegidos

### **Como cadastrar editoras:**
Exemplo de corpo para POST `/editoras`:
```json
{
  "nome": "Editora Moderna",
  "pais": "Brasil",
  "livros": []
}
```

### **Como cadastrar livros:**
Exemplo de corpo para POST `/livros` (usando o id da editora já cadastrada):
```json
{
  "titulo": "Matemática Essencial",
  "autor": "Carlos Silva",
  "preco": 59.90,
  "editora": {
    "id": 1
  }
}
```

---

## 🔒 **Resumo dos Endpoints**
- **Abertos:**
  - `/actuator/health` — Health check
  - `/swagger-ui/index.html` — Documentação e testes
- **Protegidos (JWT):**
  - `/livros` (CRUD)
  - `/editoras` (CRUD)
  - `/auth/register` (POST)
  - `/auth/login` (POST)

---

## 🛠️ **Como rodar localmente**
1. Clone o repositório
2. Execute `./mvnw spring-boot:run` ou use o Dockerfile
3. Acesse `http://localhost:8080/swagger-ui/index.html`

---

## 📊 **Monitoramento**
- Health: `/actuator/health`
- Métricas: `/actuator/metrics`
- Prometheus: `/actuator/prometheus`

---

## 📦 **Deploy**
- O deploy foi realizado no Render, sem necessidade de Docker local
- NÃO ESTOU USANDO MAIS Railway App
- Basta subir o código para o GitHub e configurar o serviço no Render

---

## 📚 **Links úteis**
- [Swagger UI da API](https://av2-96x7.onrender.com/swagger-ui/index.html)
- [Health Check](https://av2-96x7.onrender.com/actuator/health)
- [Repositório no GitHub](https://github.com/brksam/av2)

---

**Dúvidas ou problemas?** Abra uma issue no repositório ou entre em contato! 
