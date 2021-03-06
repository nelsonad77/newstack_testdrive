#!/bin/bash

echo "####  Making VIM feel right ####"

cat << 'EOF' >> ~/.vimrc
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
colo torte              " set colorscheme
syntax on               " syntax highlighing on
set expandtab           " tabs are spaces
set softtabstop=4       " number of spaces in tab when editing
set tabstop=4           " number of visual spaces per TAB
EOF

# We need to change the hostname of this host. Note that it's "linux" on the FA
# and it's "Linux" on the host.

echo "#### Changing hostname ####"

echo "linux" > /etc/hostname
systemctl restart systemd-hostnamed
sleep 3

HNAME=$(hostname)

for lname in 'linux';do
    if [ "$HNAME" = "$lname" ]; then
        echo "Hostname is linux, matches FlashArray."
    else
        echo "Hostname still needs to be changed!"
    fi
done


#systemctl restart multipathd
#/usr/sbin/multipath -r

git config --global user.name "ccrow42"
git config --global user.email chris@ccrow.org

# Save a second and create a mount point in /mnt - Actually, Ansible will create the mount point.
# mkdir /mnt/ansible-src

# Typing "ansible-playbook" everytime is a hassle...
echo "" >> ~/.bashrc


# Should be able to remove this after 1.23 is released

yum install redhat-lsb-core libibverbs python3 python3-devel -y
sudo python3 -m pip install python-memcached
cd /root
git clone https://git.openstack.org/openstack-dev/devstack
cd /root/devstack
git checkout stable/train

#Host IP issue. I have no clue why we aren't picking up from local.conf
#export HOST_IP="10.0.1.215"
export HOST_IP="172.16.3.11"


#export USE_PYTHON3=true


/root/devstack/tools/create-stack-user.sh
chmod 755 /opt/stack
chmod 777 /root -R
cp -rfv /root/newstack_testdrive/openstack/local.conf /root/devstack
#cp -rfv /root/newstack_testdrive/openstack/apache /root/devstack/lib
#Let's use a patch instead
git apply /root/newstack_testdrive/openstack/lib_apache.patch

# vanilla install was complaining about a lack of python modules. Installed with PIP
# Don't use this!
#pip install purestorage


echo "############ PAY ATTENTION ###############"
echo "please execute /root/devstack/stack.sh after su - stack"
echo "Also run pip install purestorage as root AFTER executing stack.sh"

# Note that the first  failure is on the permissions of the /opt/stack directory
# chmod 755 /opt/stack seems to allow us to move paste

# The next failure is around this bug: https://bugs.launchpad.net/devstack/+bug/1883468
# Still working to resolve that one. Resolved with the patched apache script. Now we are stuck on stable/train
