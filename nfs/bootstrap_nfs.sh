
echo "[TASK 2mount ] Download and install NFS server"
sudo apt update
sudo apt install -y nfs-kernel-server

echo "[TASK 3] Create a kubedata directory"
sudo mkdir -p /srv/nfs/kubedata
sudo mkdir -p /srv/nfs/kubedata/db
sudo mkdir -p /srv/nfs/kubedata/storage
sudo mkdir -p /srv/nfs/kubedata/logs

echo "[TASK 4] Update the shared folder access"
sudo chown nobody:nogroup srv/nfs/kubedata
chmod -R 777 /srv/nfs/kubedata

echo "[TASK 5] Make the kubedata directory available on the network"
cat >>/etc/exports<<EOF
/srv/nfs/kubedata    *(rw,sync,no_subtree_check,no_root_squash)
EOF

echo "[TASK 6] Export the updates"
sudo exportfs -rav

echo "[TASK 7] Enable NFS Server"
sudo systemctl restart nfs-kernel-server

echo "[TASK 8] Start NFS Server"
sudo systemctl stsrart nfs-server