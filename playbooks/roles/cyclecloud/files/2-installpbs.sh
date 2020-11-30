#!/bin/bash

wget https://github.com/PBSPro/pbspro/releases/download/v19.1.1/pbspro_19.1.1.centos7.zip
unzip pbspro_19.1.1.centos7.zip
yum install epel-release -y
yum install -y pbspro_19.1.1.centos7/pbspro-execution-19.1.1-0.x86_64.rpm jq

sed -i 's/CHANGE_THIS_TO_PBS_PRO_SERVER_HOSTNAME/scheduler/' /etc/pbs.conf
sed -i 's/CHANGE_THIS_TO_PBS_PRO_SERVER_HOSTNAME/scheduler/' /var/spool/pbs/mom_priv/config


# Retrieve the VMSS name to be used as the pool name for multiple VMSS support
poolName=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2018-10-01" | jq -r '.compute.vmScaleSetName')
/opt/pbs/bin/qmgr -c "c n $(hostname)" || exit 1
/opt/pbs/bin/qmgr -c "s n $(hostname) resources_available.slot_type=$(jetpack config pbspro.slot_type)" || exit 1
/opt/pbs/bin/qmgr -c "s n $(hostname) resources_available.ungrouped=false" || exit 1
/opt/pbs/bin/qmgr -c "s n $(hostname) resources_available.group_id=${poolName}" || exit 1

systemctl restart pbs
