#/bin/bash
user=mingguangzhen
#adduser -G wheel $user
useradd $user
sudo mkdir -p /home/${user}/.ssh
sudo chmod 700 /home/${user}/.ssh
sudo cat > /home/${user}/.ssh/authorized_keys <<'EOF'
ssh-dss AAAAB3NzaC1kc3MAAACBAJAygXgmiPYz1IJgDifpI3s4cxNLDU17Oc1kFX1YC4y1Yc6DiviRiZa2kQqnX/SV5OVDvksT8COZg8HLJTZbEBdqGBoYg7EfpSE6kOaW84UW7SBLGtRHwCstAF8ZqIoUF/9j/eNWZ2pUMDUvjocrv9/cRe89qFAr2VUy3+AFjJ5rAAAAFQDSo+yqOqL2jH+adnNyqgipniDF1wAAAIAGcvTSbMYWgf1KdNW4Pwd4Pe3hPQZsn7QVUz1hR+23kPC45iKoqmTYJSUScmhVT2U6njGTjx0F1UdVfAx0PkFCRYModpXoCbjIT1p64V56SCfNmndHq9352H36Bt1KShbEa/SO5l2bjNiTIDkRZKKNhkd9P8egFgC5wUi74cge/AAAAIAiGoZyt7IbYVqmBsdLT7s8LhqFukbCY34B5eoaTyQEbs6O84YjfdmTA4z2t8QY9FdzV/NoKqe3Nq6Ltn84yz72Er9+pvcKxH6ngdISVpYc6NfIUfOUddje7Iqf2oYCwKQdBZ6SsLrNRxDpe1uFs6Mj+VQfqfLMXKLdCLCwuMxZGg==
EOF
sudo chmod 0600 /home/${user}/.ssh/authorized_keys
sudo chown -R ${user}:${user} /home/${user}/.ssh