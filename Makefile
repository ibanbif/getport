project = devops
env     = lab
service = getport
domain  = punkerside.io

export AWS_DEFAULT_REGION=us-east-1

init:
	cd terraform/${appName}/ && terraform init

apply:
	cd terraform/${appName}/ && terraform apply -var project=${project} -var env=${env} -var service=${service} -var domain=${domain}

destroy:
	cd terraform/${appName}/ && terraform destroy -var project=${project} -var env=${env} -var service=${service} -var domain=${domain}