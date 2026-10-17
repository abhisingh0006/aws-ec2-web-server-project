# AWS EC2 Web Server with EBS, Snapshot, and AMI

A hands-on AWS project that deploys a web page on Amazon Linux 2023 using EC2 and Apache, attaches and mounts an additional EBS volume, creates a snapshot and an AMI, and launches a second EC2 instance from that AMI.

## Architecture

- **Amazon EC2** — runs the Linux web server.
- **Apache (httpd)** — serves the website over HTTP.
- **Security Group** — permits HTTP traffic on port 80 and SSH on port 22.
- **Amazon EBS** — an additional 2 GiB `gp3` data volume mounted at `/data`.
- **EBS Snapshot** — point-in-time backup of the additional data volume.
- **Amazon Machine Image (AMI)** — reusable image created from the web server.
- **Second EC2 instance** — launched from the AMI to verify that the website can be replicated.

## Website preview

The page is in [`website/index.html`](website/index.html). To preview locally, open that file in a browser.

## What I implemented

1. Launched an Amazon Linux 2023 EC2 instance.
2. Connected to the instance from Windows PowerShell using SSH and a `.pem` key.
3. Installed and enabled Apache (`httpd`).
4. Created a web page and served it from `/var/www/html/index.html`.
5. Created a 2 GiB `gp3` EBS volume in the same Availability Zone as the EC2 instance.
6. Attached the volume and identified the new disk with `lsblk`.
7. Created an XFS filesystem and mounted the disk at `/data`.
8. Verified the mount with `df -h /data` and `lsblk`.
9. Created an EBS snapshot.
10. Created an AMI from the web server.
11. Launched a second EC2 instance from the AMI and verified the site over HTTP.

## Repository structure

```text
aws-ec2-web-server-project/
├── README.md
├── .gitignore
├── LICENSE
├── website/
│   └── index.html
└── scripts/
    └── user-data.sh
```

## Deployment notes

### 1. Launch EC2

- AMI: Amazon Linux 2023
- Instance type: choose an instance type eligible for your account and budget
- Key pair: create or select your own key pair
- Security group inbound rules:
  - SSH, TCP 22: **My IP only**
  - HTTP, TCP 80: `0.0.0.0/0` for a public demo website
- Use the same AWS Region and Availability Zone when attaching EBS.

### 2. Install Apache

Connect with SSH, then run:

```bash
sudo dnf update -y
sudo dnf install -y httpd
sudo systemctl enable --now httpd
```

Copy `website/index.html` to `/var/www/html/index.html` on the server. One way is to use `scp` from your local machine, or paste the file content into the server using a text editor.

### 3. Add the EBS data volume

Create a new `gp3` volume (for example, 2 GiB) in the **same Availability Zone** as your EC2 instance, then attach it.

Identify the new disk before formatting:

```bash
lsblk
```

On the completed lab, the root disk was 8 GiB and the new disk was 2 GiB. Device names vary by instance; on Nitro-based instances an attached EBS volume often appears as `/dev/nvme1n1`. **Never assume the device name—verify it with `lsblk` before formatting.**

If the new, empty disk is confirmed to be `/dev/nvme1n1`, format and mount it:

```bash
sudo mkfs.xfs /dev/nvme1n1
sudo mkdir -p /data
sudo mount /dev/nvme1n1 /data
df -h /data
lsblk
```

Formatting erases data on the selected device. Do not run `mkfs` on the root disk or on a disk containing data you need.

### 4. Create a snapshot and AMI

- For the data volume: **EC2 → Volumes → select volume → Actions → Create snapshot**.
- For the server image: **EC2 → Instances → select instance → Actions → Image and templates → Create image**.
- Wait until the AMI status becomes **Available**.

### 5. Launch a second instance

Launch an instance from the created AMI. Confirm its security group permits HTTP on port 80, wait for status checks to pass, and open its public IPv4 address using `http://`.

## Optional user data

The file [`scripts/user-data.sh`](scripts/user-data.sh) is a bootstrap script for a new Amazon Linux 2023 instance. Paste its contents into **Advanced details → User data** during launch. It installs Apache and writes the demo page. User data runs on first boot by default.

## Security and cost reminders

- Never commit `.pem` private keys, passwords, access keys, or other secrets to GitHub.
- Restrict SSH (port 22) to **My IP**, rather than exposing it to everyone.
- Public HTTP access is appropriate for a public demo, but avoid publishing sensitive content.
- EC2 instances, EBS volumes, snapshots, and AMI backing snapshots can incur charges. Review AWS pricing and delete lab resources you no longer need.
- Stopping an EC2 instance does not automatically remove EBS volumes or snapshots.

## Evidence to add to this repository

Consider adding your own screenshots to a `screenshots/` folder:
- First website in the browser
- EBS volume mounted at `/data`
- Snapshot status
- AMI status showing `Available`
- Second instance serving the website

Only add screenshots that do not expose account IDs, private keys, credentials, or other sensitive information.

## Skills demonstrated

Amazon EC2 · Amazon EBS · Linux · SSH · Apache/httpd · Security Groups · XFS · EBS Snapshots · AMIs · Basic HTML/CSS/JavaScript · Git and GitHub
