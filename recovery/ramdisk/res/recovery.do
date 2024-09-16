
on init-recovery
	mount /system

	unmount /cache	
	exec -f "/system/bin/e2fsck -v -y <dev_node:/cache>"

	mount -f /cache
	cat -f --no-exist /cache/recovery/command > /cache/recovery/last_command
	ls /cache/recovery/
	ls /cache/fota/
	
	fcut --limited-file-size=256k -f /cache/recovery/last_recovery /tmp/recovery_backup.txt
	cp -y -f -v /tmp/recovery_backup.txt /cache/recovery/last_recovery

on multi-csc
	echo 
	echo "-- Appling Multi-CSC..."
	mount /system	
	echo "Applied the CSC-code : <salse_code>"
	cp -y -f -r -v /system/csc/common /
	unmount /system
	mount /system
	cmp -r /system/csc/common /	
	cp -y -f -r -v /system/csc/<salse_code>/system /system
	rm -v /system/csc_contents
	ln -v -s /system/csc/<salse_code>/csc_contents /system/csc_contents
	unmount /system
	mount /system	
	cmp -r /system/csc/<salse_code>/system /system
	rm -v --limited-file-size=0 /system/app/*
	echo "Successfully applied multi-CSC."

on multi-csc-data
	unmount -f /system
	mount /data
	cp -y -f -r -v --with-fmode=0644 --with-dmode=0771 --with-owner=system.system /data/csc/common /
	cp -y -f -r -v --with-fmode=0644 --with-dmode=0771 --with-owner=system.system /data/csc/<salse_code> /
	rm -v --limited-file-size=0 /data/app/*	
	rm -v -r -f /data/csc
	unmount /data

on factory-out
	echo "-- Copying media files..."
	mount /data
	mount /system
	mkdir media_rw media_rw 0770 /data/media
	cp -y -r -v -f --with-fmode=0664 --with-dmode=0775 --with-owner=media_rw.media_rw /system/hidden/INTERNAL_SDCARD/ /data/media/
	unmount /data
	mount /data
	cmp -r /system/hidden/INTERNAL_SDCARD/ /data/media/

	echo "--  preload checkin..."
	precondition define /preload

	mount -f /preload
	precondition mounted /preload

	cp -y -r -v -f --with-fmode=0664 --with-dmode=0775 --with-owner=media_rw.media_rw /preload/INTERNAL_SDCARD/ /data/media/
	unmount /data
	mount /data
	cmp -r /preload/INTERNAL_SDCARD/ /data/media/

on recovery-out
	mount /data
	mkdir system log 0775 /data/log

on resizing-data
	mount /system

	mount /data
	find -v --print=/tmp/data.list /data
	unmount /data

	loop_begin 2
		exec "/system/bin/e2fsck -y -f -e <dev_node:/data>"
		exec "/system/bin/resize2fs -R 16384 <dev_node:/data>"
	loop_end

	mount /data
	df /data
	verfiy_data <dev_node:/data> /data 5
	verfiy_data --size-from-file=/tmp/data.list
	unmount /data

on format-carrier
	precondition define /carrier
	mount -r /carrier
	format /carrier
	unmount /carrier
