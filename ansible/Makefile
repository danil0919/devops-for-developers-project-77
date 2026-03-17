.PHONY: ping deploy-postgres deploy-focalboard deploy-datadog deploy-app

ping:
	ansible all -m ping

deploy-postgres:
	ansible-playbook playbook.yml --tags postgres --ask-vault-pass

deploy-focalboard:
	ansible-playbook playbook.yml --tags focalboard --ask-vault-pass

deploy-datadog:
	ansible-playbook playbook.yml --tags datadog --ask-vault-pass

deploy-app:
	ansible-playbook playbook.yml --ask-vault-pass