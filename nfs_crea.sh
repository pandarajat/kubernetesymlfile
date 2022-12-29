sudo apt updates
sudo apt install nfs-kernel-server
sudo mkdir -p /mnt/nfs_share
sudo chown -R nobody:nogroup /mnt/nfs_share/
sudo chmod 777 /mnt/nfs_share/
sudo nano /etc/exports
/mnt/nfs_share *(rw,sync,no_subtree_check,no_root_squash) # no_root_squash ---> use 

sudo exportfs -a

 sudo systemctl restart nfs-kernel-server

# in server system 
sudo apt install -y nfs-common
 sudo mount 172.31.36.163:/mnt/nfs_share /mnt/nfs_share