# Steps

1. Downgrade N1 bootloader to make flash avaliable
2. 

# Downgrade N1 bootloader to make flash avaliable

follow steps from [this post](https://www.right.com.cn/forum/thread-340279-1-1.html).

1. connect wired mouse to N1
1. Install google usb driver
2. disconnect usb cable
3. open adb(click on version 4 times)
4. adb connect ip
5. connect usb cable
1. Download one-key tool from [百度云:0uxv](https://pan.baidu.com/s/1KBxq4MveOAQ-n4pBOcfrHQ) or [微云:yaefa9](https://share.weiyun.com/5klmuxd)
2. extrace downloaded files
3. run 

# Pitfalls

## No1. adb cannot find device

tried install amlogic USB Burnning tool, google USB driver, reboot, 
all not working.

### probably step(Incorrect, tried without USB cable and connected):
0. copy AdbWinApi.dll, AdbWinUsbApi.dll to system dir
1. Disconnect USB cable to N1;
2. Connect wired mouse to 2nd USB port from HDMI port on N1;
3. Power on N1;
4. Turn on adb debug (mouse click version number 4 times)
5. Connect USB cable to 1st USB port from HDMI port on N1;
6. run:
```
adb kill-server
adb connect ip
adb devices -l
```
7. Now see something like "product:p230 model:p230 device:p230" 

### Tried step2(success)
0. copy AdbWinApi.dll, AdbWinUsbApi.dll to system dir
1. power on N1, which has adb already enabled. *note* N1 led keeps blinking.
2. run adb commands, and successfully connected.


## No2. cannot ssh

sshd does not autostart, maybe media fault. 
```
ssh-keygen -A
mkdir -p /run/sshd
```
after fixed it, cannot ssh
from other computer.
no solution, just reinstalled.

## No3. cannot find rootfs after first boot from emmc

run install.sh to install armbian to emmc, the first rebook was ok,
and it said "Warning: a reboot is needed to finish resizing the filesystem". After reboot, it cannot find partition with label "ROOT_EMMC", which is used for rootfs.

solution:
redo the create boot and root fs, and copy boot and root files
procedure as install.sh. The simple way would be delete lines before "Start copy system for eMMC", and set variables ${DEV_EMMC}, then run the halved script.
