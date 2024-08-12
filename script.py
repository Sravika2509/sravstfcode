import os
import subprocess
import json

def terragrunt_run(env, account, dev, region, resource_name, action):
    """
    Construct the directory path and execute the Terragrunt command.
    
    :param env: The environment (e.g., dev, prod).
    :param account: The AWS account identifier.
    :param dev: The development identifier.
    :param region: The AWS region (e.g., us-east-1).
    :param resource_name: The name of the resource (directory) to target.
    :param action: The Terragrunt action to perform ('apply' or 'destroy').
    """
    directory = f"/{env}/eec-aws-{account}-eits-egpt-{dev}/{region}/modules/{resource_name}"
    
    if not os.path.exists(directory):
        print(f"Directory {directory} does not exist.")
        return

    os.chdir(directory)
    print(f"Running Terragrunt in {os.getcwd()}")

    # Terragrunt init
    subprocess.run(f"terragrunt init", shell=True, check=True)

    # Terragrunt plan
    subprocess.run(f"terragrunt plan", shell=True, check=True)

    # Terragrunt apply or destroy
    if action == "create":
        subprocess.run(f"terragrunt apply -auto-approve", shell=True, check=True)
    elif action == "destroy":
        subprocess.run(f"terragrunt destroy -auto-approve", shell=True, check=True)

    os.chdir("../../")

def main():
    # Hardcoded environment details
    env = "dev"
    account = "123456789012"
    dev = "dev"
    region = "us-east-1"

    # Load the JSON input
    with open('input.json') as f:
        data = json.load(f)

    action = data.pop("action", None)
    
    for resource_name, enabled in data.items():
        if enabled == "y":
            print(f"####### {resource_name} {action} is in-progress.. ###########")
            terragrunt_run(env, account, dev, region, resource_name, action)

if __name__ == "__main__":
    main()
