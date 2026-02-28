import json
import os
import subprocess
import sys

# Paths relative to the script
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
terraform_dir = os.path.join(base_dir, "terraform")
template_path = os.path.join(base_dir, "vyos-ha-config.txt")
output_path_a = os.path.join(base_dir, "vyos-router-a-config.txt")
output_path_b = os.path.join(base_dir, "vyos-router-b-config.txt")

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

def build_config(template_content, router_name, tunnel_name, aws_tunnel_ip, psk, vti_local, vti_remote, internal_ip, vrrp_priority, bgp_asn, aws_bgp_asn="64512"):
    config = template_content
    config = config.replace("<ROUTER_NAME>", router_name)
    config = config.replace("<TUNNEL_NAME>", tunnel_name)
    config = config.replace("<AWS_TUNNEL_IP>", aws_tunnel_ip)
    config = config.replace("<PRE_SHARED_KEY>", psk)
    config = config.replace("<VTI_LOCAL_IP>", vti_local)
    config = config.replace("<VTI_REMOTE_IP>", vti_remote)
    config = config.replace("<ROUTER_INTERNAL_IP>", internal_ip)
    config = config.replace("<VRRP_PRIORITY>", vrrp_priority)
    config = config.replace("<BGP_ASN>", bgp_asn)
    config = config.replace("<AWS_BGP_ASN>", aws_bgp_asn)
    return config

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
        template_content = f.read()

    # Generate Router A config (uses Tunnel 1)
    config_a = build_config(
        template_content,
        router_name="Router-A",
        tunnel_name="Tunnel 1",
        aws_tunnel_ip=details["tunnel1_address"],
        psk=details["tunnel1_preshared_key"],
        vti_local=details["tunnel1_cgw_inside_address"],
        vti_remote=details["tunnel1_vgw_inside_address"],
        internal_ip="192.168.0.2",
        vrrp_priority="200",
        bgp_asn="65000",
        aws_bgp_asn=str(details.get("tunnel1_bgp_asn", "64512"))
    )

    with open(output_path_a, "w") as f:
        f.write(config_a)

    # Generate Router B config (uses Tunnel 2)
    config_b = build_config(
        template_content,
        router_name="Router-B",
        tunnel_name="Tunnel 2",
        aws_tunnel_ip=details["tunnel2_address"],
        psk=details["tunnel2_preshared_key"],
        vti_local=details["tunnel2_cgw_inside_address"],
        vti_remote=details["tunnel2_vgw_inside_address"],
        internal_ip="192.168.0.3",
        vrrp_priority="100",
        bgp_asn="65000",
        aws_bgp_asn=str(details.get("tunnel2_bgp_asn", "64512"))
    )

    with open(output_path_b, "w") as f:
        f.write(config_b)

    print(f"Successfully generated configs for Router-A ({output_path_a}) and Router-B ({output_path_b})")

    if "aws_private_ip" in outputs:
        target_ip = outputs["aws_private_ip"]["value"]
        print("\nSetup complete! Run this on your Vagrant VMs respectively.")

if __name__ == "__main__":
    main()
