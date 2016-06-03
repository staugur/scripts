#/bin/bash
user=gantian
useradd -G wheel $user
sudo mkdir -p /home/${user}/.ssh
sudo chmod 700 /home/${user}/.ssh
sudo cat > /home/${user}/.ssh/authorized_keys <<'EOF'
ssh-rsa AAAAB3NzaC1kc3MAAACBAK8QtnJm8XWCpaWLtRfjvj3Y71BGVdK7i+2TFY1faenjR/BBIYQjqB0VxzRi2neXAiNCFlqjhBst/+AgvBDFTJXGxKC1RH5V9W2r/8RJt9h0tWsEowq9KnEmW20U83BLJRcEY/Dcpu1XzxWB/WK4I0xdcrCzSZo0QBpTIr7Eh3NTAAAAFQCbkL3iePcxahfWuopktpTry+It4wAAAIBIcxlXlQHjLn4l7PVknYTiCEDs+CbS0edo99+Lp7GFULu4cd3199IK+hw2MYQld2XXyGKIHFgdMSVAlJAi6oGqz4UuV+huS43aj4lpEH/wYCLW+7sQzwosbRCDArX0zunF2S9wpkXi4eIEYKOGRbibzzVk1NktAWi14BkdQ1ZAlQAAAIB+KmaiGCzGBkUGOAaS0EaiA9oBLSizO7K+kUaG077Vm15hmscYLkE1Ld79wcdhxq079AEJKr3qrIPOzZkrsuhYbLCCL63Xs5Dl3cVHvNujYE2crxPQgskUDNz0Udzatqd4zy/a7WGZx7WNbvgPLJc4cAFBiweXEuceoSpPPX09oQ==
EOF
sudo chmod 0600 /home/${user}/.ssh/authorized_keys
sudo chown -R ${user}:${user} /home/${user}/.ssh