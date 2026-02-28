# 🔍 Lab 01: Troubleshooting & Engineering Logs

This guide documents the common "failure points" encountered during the setup of a Site-to-Site VPN and the diagnostic commands used to resolve them.

### 1. The Tunnel is "DOWN" (Control Plane Issues)
If the AWS Console shows the tunnel status as `DOWN`, the issue is likely in the **IKE (Phase 1)** or **IPsec (Phase 2)** negotiation.

* **Check Phase 1 (IKE) on VyOS:**
    ```bash
    show vpn ike sa
    ```
    - **If empty:** The VyOS router cannot reach the AWS public IP. Check your local firewall/ISP to ensure **UDP 500** and **UDP 4500** are open.
    - **If "Down":** There is likely a **Pre-Shared Key (PSK)** mismatch or a proposal mismatch (AES/SHA settings).

* **Check Phase 2 (IPsec) on VyOS:**
    ```bash
    show vpn ipsec sa
    ```
    - If Phase 1 is up but Phase 2 is down, verify that **PFS (Perfect Forward Secrecy)** is enabled and the Diffie-Hellman groups match on both sides.

### 2. Tunnel is "UP" but No Traffic (Data Plane Issues)
This is a common "Real World" scenario where the encryption is working, but the routing is not.

* **Verify Routing Table:**
    Ensure the VyOS router has a static route pointing your AWS VPC CIDR (`10.0.0.0/16`) to the VTI interface.
    ```bash
    show ip route
    ```
* **Check AWS Security Groups:**
    The private EC2 instance must allow **ICMP (Ping)** and **SSH** from your on-prem CIDR (`192.168.0.0/24`).
* **The "MTU/MSS" Trap:**
    If pings work but SSH or Web traffic hangs, the packet is likely too large for the tunnel. Ensure **MSS Clamping** is set to `1379` on the VyOS VTI interface.

### 3. Essential Diagnostic Commands
| Command | Purpose |
| :--- | :--- |
| `monitor vpn ipsec` | Real-time log tailing for IKE/IPsec negotiations. |
| `sudo tcpdump -i vti0` | Packet capture to see if traffic is entering the tunnel. |
| `show vpn ipsec status` | High-level summary of all VPN tunnels and their state. |
| `restart vpn` | Restarts the IPsec process to re-negotiate keys. |