
echo "[TASK 2mount ] Download and install NFS server"

sudo apt update
sudo apt install -y nfs-kernel-server

echo "[TASK 3] Create a kubedata directory"
sudo mkdir -p /nfs

echo "[TASK 4] Update the shared folder access"
sudo chown nobody:nogroup -R /nfs
chmod -R 777 /srv

echo "[TASK 5] Make the kubedata directory available on the network"
cat >>/etc/exports<<EOF
/nfs    *(rw,sync,no_subtree_check,no_root_squash)
EOF

echo "[TASK 6] Export the updates"
sudo exportfs -rav

echo "[TASK 7] Enable NFS Server"
sudo systemctl restart nfs-kernel-server

echo "[TASK 8] Start NFS Server"
sudo systemctl restart nfs-server