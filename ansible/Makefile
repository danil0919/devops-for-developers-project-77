.PHONY: ping deploy-postgres deploy-focalboard deploy-datadog deploy-app

ping:
	ansible all -m ping

deploy-postgres:
	ansible-playbook playbooks/postgres.yml --ask-vault-pass

deploy-focalboard:
	ansible-playbook playbooks/focalboard.yml --ask-vault-pass

deploy-datadog:
	ansible-playbook playbooks/datadog.yml --ask-vault-pass

deploy-app:
	$(MAKE) deploy-postgres
	$(MAKE) deploy-focalboard
	$(MAKE) deploy-datadog