terraform-init:
	cd terraform && terraform init

terraform-apply:
	cd terraform && terraform apply -auto-approve

terraform-destroy:
	cd terraform && terraform destroy -auto-approve

generate-inventory:
	./scripts/generate_ansible_inventory.sh

infra:
	make terraform-init
	make terraform-apply
	make generate-inventory

ansible-ping:
	cd ansible && ansible all -m ping

deploy-postgres:
	cd ansible && ansible-playbook playbooks/postgres.yml --ask-vault-pass

deploy-focalboard:
	cd ansible && ansible-playbook playbooks/focalboard.yml --ask-vault-pass

deploy-app:
	make deploy-postgres
	make deploy-focalboard