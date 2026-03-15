### Hexlet tests and linter status:
[![Actions Status](https://github.com/danil0919/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/danil0919/devops-for-developers-project-77/actions)


# DevOps Focalboard Infrastructure

Учебный DevOps-проект для развёртывания **Mattermost Focalboard** в **Yandex Cloud**.

Используется:

- Terraform — инфраструктура
- Ansible — настройка серверов и деплой
- Yandex Application Load Balancer
- PostgreSQL на отдельной VM
- Yandex Object Storage — удалённый Terraform backend

Инфраструктура:

DNS → Application Load Balancer → 2× Focalboard VM → PostgreSQL VM

---

# Требования

Установить:

- terraform
- ansible
- yc CLI

И авторизоваться:

```bash
yc init
```

# Настройка Terraform backend

Terraform state хранится в Yandex Object Storage.

Перед запуском Terraform необходимо задать переменные окружения:

```bash
export AWS_ACCESS_KEY_ID=<S3_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<S3_SECRET>
```

Ключи создаются через:

```bash
yc iam access-key create --service-account-id <SERVICE_ACCOUNT_ID>
```

Важно:

AWS_ACCESS_KEY_ID = access_key.key_id
AWS_SECRET_ACCESS_KEY = secret


# Развёртывание инфраструктуры

## Создание инфраструктуры:

```bash
make infra
```

Деплой приложения

```bash
make deploy-app
```


Приложение доступно по:

https://cheap-domen-for-devops-education.asia