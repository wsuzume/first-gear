EDITOR=vim
TRUE_INVENTORY=~/config/ignite

copy_inventory:
	./script/copy_inventory.sh ${TRUE_INVENTORY}

.SILENT:
true_inventory:
	echo ${TRUE_INVENTORY}

root:
	ansible-playbook -i inventory/root/inventory root/playbook.yml
