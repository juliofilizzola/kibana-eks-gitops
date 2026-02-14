ENV ?= dev

.PHONY: init plan apply destroy

init:
	@echo "Initializing project in environment: $(ENV)"
	cd infra/environments/$(ENV) && terraform init

plan:
	@echo "Planning infrastructure changes in environment: $(ENV)"
	cd infra/environments/$(ENV) && terraform plan

apply:
	@echo "Applying infrastructure changes in environment: $(ENV)"
	cd infra/environments/$(ENV) && terraform apply -auto-approve

destroy:
	@echo "Destroying infrastructure in environment: $(ENV)"
	cd infra/environments/$(ENV) && terraform destroy -auto-approve
