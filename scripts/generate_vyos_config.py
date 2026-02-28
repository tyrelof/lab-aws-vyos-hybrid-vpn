import json
import os
import subprocess
import sys

# Paths relative to the script
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
terraform_dir = os.path.join(base_dir, "terraform")
template_path = os.path.join(base_dir, "vyos-config.txt")
output_path = os.path.join(base_dir, "vyos-config-generated.txt")

def get_terraform_output():
    try:
        print("Retrieving Terraform outputs...")
        result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=terraform_dir,
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error retrieving Terraform outputs: {e.stderr}")
        sys.exit(1)
    except FileNotFoundError:
        print("Terraform executable not found. Please ensure it is installed and in your PATH.")
        sys.exit(1)

def main():
    if not os.path.exists(template_path):
        print(f"Template not found at {template_path}")
        sys.exit(1)

    outputs = get_terraform_output()
    if "vpn_tunnel_details" not in outputs:
        print("Required output 'vpn_tunnel_details' not found in Terraform state. "
              "Did you successfully run 'terraform apply'?")
        sys.exit(1)

    details = outputs["vpn_tunnel_details"]["value"]

    with open(template_path, "r") as f:
        config = f.read()

    # Replacements based on Terraform output
    config = config.replace("<AWS_TUNNEL_1_IP>", details["tunnel1_address"])
    config = config.replace("<PRE_SHARED_KEY>", details["tunnel1_preshared_key"])
    config = config.replace("<VTI_LOCAL_IP>", details["tunnel1_cgw_inside_address"])
    config = config.replace("<VTI_REMOTE_IP>", details["tunnel1_vgw_inside_address"])

    with open(output_path, "w") as f:
        f.write(config)

    print(f"Successfully generated automated VyOS configuration at {output_path}")

    # Display final command if aws_private_ip is available
    if "aws_private_ip" in outputs:
        target_ip = outputs["aws_private_ip"]["value"]
        print("\nSetup complete! Run this on your Vagrant VM:")
        print(f"./validate_connectivity.sh {target_ip}")

if __name__ == "__main__":
    main()
