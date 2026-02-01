.PHONY: init plan apply

init:
	@echo "Initializing project..."
	# Add initialization commands here
	cd infra && terraform init

plan:
	@echo "Planning infrastructure changes..."
	# Add planning commands here
	cd infra && terraform plan

apply:
	@echo "Applying infrastructure changes..."
	# Add apply commands here
	cd infra && terraform apply -auto-approve