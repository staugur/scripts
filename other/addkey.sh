#/bin/bash
user=zhaoziyuan
useradd -G docker $user
sudo mkdir -p /home/${user}/.ssh
sudo chmod 700 /home/${user}/.ssh
sudo cat > /home/${user}/.ssh/authorized_keys <<'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAvBVcPNfIWM6QdQP/dxviiPUrr9Q+29alyOcySZErvBF6gesO3s23aCvU00eXfz1WmixiLeiK41BhOBd4ZO/WZjU59K+/dgbpgg0ECg+tH2e57za1AWgzWIGtI93H5EiRwCTcQnlZ0HG1TiQRUJixk40e7qRUJ3O+kG9gDkKy8ZM=
EOF
sudo chmod 0600 /home/${user}/.ssh/authorized_keys
sudo chown -R ${user}:${user} /home/${user}/.ssh