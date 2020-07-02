斐讯N1折腾
===========

参考资料
-----------
- [docker 中运行 openwrt](https://github.com/lisaac/openwrt-in-docker)
- another[docker 运行 openwrt](https://github.com/luoqeng/OpenWrt-on-Docker)
- [Use macvlan networks](https://docs.docker.com/network/macvlan/)
- [斐讯N1 – 完美刷机Armbian教程](https://yuerblog.cc/2019/10/23/%e6%96%90%e8%ae%afn1-%e5%ae%8c%e7%be%8e%e5%88%b7%e6%9c%baarmbian%e6%95%99%e7%a8%8b/)
- [N1刷Armbian系统并在Docker中安装OpenWrt旁路由的详细教程](https://www.right.com.cn/forum/thread-1347921-1-1.html)
- [N1盒子做旁路由刷OpenWRT系统（小白专用）](https://www.cnblogs.com/neobuddy/p/n1-setup.html)
- [Docker上运行Lean大源码编译的OpenWRT（初稿）](https://openwrt.club/93.html)
- [engineerlzk 的CSDN博客](https://me.csdn.net/engineerlzk)
- [我在用的armbian版本](https://github.com/kuoruan/Build-Armbian/releases/tag/v5.99-20200408)

前言
-------------

### 斐讯(Phicomm) N1基本配置为：

| 项目     | 规格    |
|:--------:|---------|
| CPU      | s905    |
| 内存     | 2GB     |
| EMMC     | 8GB     |
| 有线网络 | 1000M   |
| USB      | 2.0 x 2 |
| 电源     | 12v2A   |

### armbian发展历程，国内情况
(先挖个坑，填不填看心情）

材料/软件准备
--------------

1. HDMI接口显示器一台，以及HDMI线；USB键盘鼠标各一。
2. 8G以上U盘一个（按我装的DEBIAN版本2G就够，不确定太大是否有问题）。
3. 恩山论坛@webpad的[N1降级工具](https://www.right.com.cn/forum/thread-340279-1-1.html)。
4. rufus(windows)，或其他启动盘制作工具。
5. [armbian的安装镜像](https://github.com/kuoruan/Build-Armbian/releases/tag/v5.99-20200408)。
6. ssh工具。我使用的是WSL2(ubuntu)自带的ssh。

开始之前，请先用上面的工具/材料制作好armbian的usb启动盘。windows下使用rufus或其他类似工具，linux
下可用命令，参考：
```
xzcat --keep Armbian_5.77_Aml-s905_Debian_stretch_default_5.0.2_desktop_20190318.img.xz | sudo dd of=/dev/sdX bs=1M && sync

```

刷机
-------------

### N1降级

据说pdd来的N1（未刷机）原生系统版本不支持直接刷机，需要先刷入恩山论坛@webpad制作的boot分区镜像。

操作步骤：

1. N1接HDMI，接USB键盘鼠标，开机。
2. 在天天链的主界面，鼠标点击版本号4次开启adb调试。
3. 抄下N1的IP地址：xxx.xxx.xxx.xxx。
4. 运行N1降级工具，按提示填写N1的IP地址。
5. 按提示完成降级过程。

看了@webpad提供的批处理文件，降级过程主要是这样的：
```
adb connect xxx.xxx.xxx.xxx
adb shell setprop service.phiadb.root 1
adb shell setprop service.adb.root 1
adb kill-server

adb connect xxx.xxx.xxx.xxx
adb push n1\boot.img /sdcard/boot.img
adb shell dd if=/sdcard/boot.img of=/dev/block/boot
adb shell rm -f /sdcard/boot.img
```
前面的部分setprop然后重新连接没有去查原因，估计是不设置的话会没有权限运行那个dd命令。

如上述步骤顺利完成，N1已成功降级，但*界面不会有变化*，也不会自动从U盘重启，这一点对新手比较坑。
我就是反复刷了好几次，发现都不会从U盘启动，还以为N1或者U盘坏了，反复刷了好几个版本的armbian，
最后才发现需要`adb shell reboot update`，在@webpad的批处理中这一步是放在重启后进入线刷模式
才执行的，我们不需要线刷，用网络连接后就可以运行上面的命令从U盘启动N1。

另外，有时候`adb connect xxx.xxx.xxx.xxx`会提示失败，似乎是运行过降级工具就会这样，这个问题
也折腾了我好久，重启N1，插USB线，把adb的dll复制到windows系统目录，注销windows登录都没用，
最后发现重启windows就好了，真是三十六计重启为上！


### 安装debian

从U盘启动N1，对emmc分区，将文件系统复制到emmc。

操作步骤：

1. 在windows的cmd命令提示符下运行（需要先进入降级工具中adb.exe的目录）：
```
adb connect xxx.xxx.xxx.xxx
adb shell reboot update
```
2. 在上面第二个命令按下回车同时，*立刻*插入制作好的u盘。
3. N1会从u盘启动，输入root密码1234后按提示修改密码，重新登录。
4. 安装dosfstools：`apt update && apt install dosfsutils`。
5. 运行`/root/install.sh`完成emmc分区，以及复制文件系统。
6. N1拔电源，拔U盘，重新插电启动，用刚才设置的root密码登录，运行`ip addr`抄下IP地址。

这个版本的debian默认启动sshd，抄下IP后N1就不再需要键盘鼠标和显示器了，以后的操作都在
通过ssh进行，可以很方便地复制粘贴代码。

有些教程提到，在天天链系统下插入U盘会导致U盘文件权限被修改无法正常启动，我似乎没有这个问题，
所以我实际是先插入U盘再运行第一步的两个命令的。

这个版本的armbian镜像有个bug：`install.sh`需要使用mkfs.vfat格式化boot分区，而系统中没有安装。
因此需要第4步：安装dosfstools。

如果网络连接有问题，参考[USTC源](http://mirrors.ustc.edu.cn/help/debian.html)说明配置软件源。

不同的armbian镜像内容不大一样，有些版本提供的安装脚本不一定叫`install.sh`，具体要看版本说明。
有些安装完后只能顺利启动一次，第二次又启动不了，从提示信息看系统在第一次启动后运行了一个调
整文件系统大小的任务，可能有参数设置不准确，导致root分区卷标改变，重启后就找不到这个分区，
无法启动。这时候可以在安装脚本中找到格式化和复制文件系统的部分，运行这部分就可以解决了。

刷机后配置环境
-------------
新建一个sudo用户（我个人不喜欢总是用root），并装点必要的软件方便使用。

1. 设置时区
```
# 查看时区是否正确（默认都是UTC，需要修改）
timedatectl

# 修改时区
sudo timedatectl set-timezone Asia/Shanghai

# 检查设置
timedatectl

```

1. 创建用户（以root用户身份）
```
adduser myname
usermod -aG sudo myname
```
然后以myname用户重新登录。

2. 参考[USTC源](http://mirrors.ustc.edu.cn/help/debian.html)说明配置软件源。
3. 安装常用工具：
```
sudo apt update
sudo apt install vim-nox git curl
```
4. 既然转了vim，就顺便装点插件，安装方法略。我用的有这些：
    > Plug 'tpope/vim-fugitive'
    > Plug 'vim-airline/vim-airline'
    > Plug 'vim-airline/vim-airline-themes'
    > Plug 'tomasiser/vim-code-dark'
    > Plug 'sheerun/vim-polyglot'
    > Plug 'scrooloose/nerdtree'
    >
5. 再修改下`~/.bashrc`，使bash显示git分支，并且在新的一行显示输入光标（有时候目录实在太长了）。

```
# 增加一个获取分支的函数
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# 修改原来的输入提示
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(parse_git_branch)\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w $(parse_git_branch)\n\$ '
fi
```
### 安装docker

参考[官方指南](https://docs.docker.com/engine/install/debian/)完成docker安装。
主要步骤如下：

```
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# 这里把官方源换成USTC，否则可能无法下载
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | sudo apt-key add -

sudo add-apt-repository \
    "deb [arch=arm64] https://mirrors.ustc.edu.cn/docker-ce/linux/debian \
    $(lsb_release -cs) \
    stable"

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# 一般docker安装时会自动设置docker用户组，下面这一行运行提示docker组已存在可不理
sudo groupadd docker
sudo usermod -aG docker $USER
# 完成以上步骤后退出账号重新登录
```

现在设置docker-hub源指向USTC源。创建`/etc/docker/daemon.json`，内容如下：
```
{
  "registry-mirrors": ["https://docker.mirrors.ustc.edu.cn/"]
}
```
似乎没什么用，可能是我这边网络问题？

然后拉下我们需要的容器镜像：
```
docker pull alpine
docker pull nginx:alpine
docker pull gitea/gitea
```

