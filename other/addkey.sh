#/bin/bash
user=zhangshiwan
adduser -G wheel $user
useradd $user
sudo mkdir -p /home/${user}/.ssh
sudo chmod 700 /home/${user}/.ssh
sudo cat > /home/${user}/.ssh/authorized_keys <<'EOF'
---- BEGIN SSH2 PUBLIC KEY ----
Subject: Administrator
×¢ÊÍ: "Administrator@zhangshiwan"
ModBitSize: 1024
AAAAB3NzaC1kc3MAAACBAKbVFyejJnxyy2UI3bL42lZToZFn2ssIg3CDnYcJlaow
98N2ZYc8GMwXBXSit2dOdqp0/GizxgZffV2emee7ULeeXcm22MNwxNa8pkJuDpOs
HYKtayPYA+i+gTRsPeQDDONc5msyRdpMJ7I8G6/6o4eIIYuOjJ4KPhxXJk5B3o03
AAAAFQDfiIJ+ZQWAmVSw1kJkMD4IxZFjpwAAAIAo+b3OKqaVb1VlaA4mn3QNVTac
X/i1kEN48pa8w++EwregDYzbVWFWaFEgfaH6jJjEm4syIA1pvNPZKeyPpzyfndqz
T32XDqdLaDRNFlxs7vvZ2j77BFGmlWS+i/Rekwd+/rGSfrE3HfO7EUg2O9X5XReR
VmEW+EF9aJQ3CMIyWQAAAIAHN370tnxaTUr1B/Q3ROs2mnaS7czFAhFEkK5ptfB2
7UgF1REn4nkWh9r3KOJa4HjBUfg3OoTZk19lk6QOSYC6K2kM7B+A9DLuZbbVYOSs
1fsZcBCXYDLhok/t5E6xkIhMEpV4YtzjYQEK/utU8Iq91Kv/sARBFfqztsLsuSiT
+Q==
---- END SSH2 PUBLIC KEY ----
EOF
sudo chmod 0600 /home/${user}/.ssh/authorized_keys
sudo chown -R ${user}:${user} /home/${user}/.ssh