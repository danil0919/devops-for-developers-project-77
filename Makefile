.PHONY: infra destroy generate-inventory ansible-ping deploy-app deploy-postgres deploy-focalboard deploy-datadog deploy

infra:
	$(MAKE) -C terraform init
	$(MAKE) -C terraform apply
	$(MAKE) generate-inventory

destroy:
	$(MAKE) -C terraform destroy

generate-inventory:
	./scripts/generate_ansible_inventory.sh

ansible-ping:
	$(MAKE) -C ansible ping

deploy-postgres:
	$(MAKE) -C ansible deploy-postgres

deploy-focalboard:
	$(MAKE) -C ansible deploy-focalboard

deploy-datadog:
	$(MAKE) -C ansible deploy-datadog

deploy-app:
	$(MAKE) -C ansible deploy-app

deploy:
	$(MAKE) infra
	$(MAKE) deploy-app