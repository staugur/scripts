#/bin/bash
user=lihuailong
#adduser -G wheel $user
useradd $user
sudo mkdir -p /home/${user}/.ssh
sudo chmod 700 /home/${user}/.ssh
sudo cat > /home/${user}/.ssh/authorized_keys <<'EOF'
-----BEGIN DSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,46E7779A57CC1BBD

fy6UbS1Ps6sud8b4X2YsAuELYKxfznQcM4+D5ClLYtOUw6LXDB4YbiE5ecHZ4pDz
Xi9lFetXmktllDrF9hy2mnTFgPSOiLfFsLwOLpVdbmOH6JU+hia0RTBkhs/qaFDv
TrJy6LFXtmGiSiym1iYZio3qWwHJaNIm1xPlcdHq+RhmT92Rxuutc8LedZ0iBv+n
ouVkxkWxUNU5wTVUwr6pQdlzgjvFKk3EFLWf5rmo7xt7HK46jX4BcEQ54RIeNVSc
pyPMq5q30W+jq2eS3whl73D8tpplUgYQi0Q9zJzuMBVc6Y3oQcKvUMmW5NaYP3Uw
voJvQVlZ8PCmCVBRuiSU8LZbl+vffCI5x+LOI8jQ2rNhQj2rjA8BPKKKNtaUKljv
e46QRYUrzdCr+WoAPdo2a8kUv5Le4bTMvuwokwybGRePttZ/o1C/3Pn9+rhqQ4Nn
uy6mfPlchNf6DX9N1ca3XdvqrQFp4sV+vzw6jeKeWTqVfyAN2rofWfdyQLns+4kS
YSlJJHoREUsGBRzSzK/Vd8HOv5hFyvRrjO2/GWd0n6ZWbaos+R9bJJEX5sgNImyz
KAUt5C+4CHhVAV9wFK3qig==
-----END DSA PRIVATE KEY-----
EOF
sudo chmod 0600 /home/${user}/.ssh/authorized_keys
sudo chown -R ${user}:${user} /home/${user}/.ssh