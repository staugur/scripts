#/bin/bash
user=lihuailong
#adduser -G wheel $user
useradd $user
sudo mkdir -p /home/${user}/.ssh
sudo chmod 700 /home/${user}/.ssh
sudo cat > /home/${user}/.ssh/authorized_keys <<'EOF'
---- BEGIN SSH2 PUBLIC KEY ----
Subject: JiFengmin
Comment: "kangpeiliang"
ModBitSize: 1024
AAAAB3NzaC1kc3MAAACBAKhrU7ovvDKEPIWvyB1+Qpo/Yt6PQrhYiB3mbb8Wroep
7ljhyMMkPkQ+6A1Sexj/Odyr+x2t+yevZJFlJrZT6k68aE4GaPStIznZSa5z5mOb
NphjPO+6tIvY3loNhChBtl4qr0Jsc5xJKq3T94ANv/d9IOEDEQL0x2J5v/5nzvJB
AAAAFQDN4MyKklara9SjWcVK+4K5HKBeBQAAAIA+FTKVv8wfYIFrgiiFXfJz3abt
hlqk/j5/RAXgqFSS2DyEGFRXmV0WGgD/ISUQcR6PguyGP1BzDlSot4UFjzEQevqE
pIiQlfeSeSWlWCpwejkdaaWVxLxhmWeYYjjFbvtg2dxrprr0TwLIPxXrql7n1vnV
ocPM329ueiMLxb8CWwAAAIAYuBhQwzkuPgB9Vm6X6jHrauk5tf8QgGH3YCYA8XXO
BIj3oehUm1eEE07k/ffNscDvGuJLaYtSzR7bsFu2tfZXTW/l3DELWE7SaBGmr8lN
bPrlCYFjWCev97dXunl3fbjrbT64+Vmu2Asm/SZkHSEfWM5z+herPtCfAgN8rY/8
xQ==
---- END SSH2 PUBLIC KEY ----
EOF
sudo chmod 0600 /home/${user}/.ssh/authorized_keys
sudo chown -R ${user}:${user} /home/${user}/.ssh