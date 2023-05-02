#!/bin/bash

# 执行脚本的根目录
base_dir=$(pwd)

# 交互式输入工作目录名称
read -p "请输入工作目录名称: " work_dir_name

# 检查并创建工作目录
work_dir="$base_dir/$work_dir_name"
if [ ! -d "$work_dir" ]; then
    echo "创建工作目录: $work_dir"
    mkdir -p "$work_dir"
fi

# 交互式输入要克隆的项目地址
read -p "请输入要克隆的项目地址: " clone_repo_path

# 安装环境变量
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
    bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext gcc-multilib g++-multilib \
    git gperf haveged help2man intltool libc6-dev-i386 libelf-dev libglib2.0-dev libgmp3-dev libltdl-dev \
    libmpc-dev libmpfr-dev libncurses5-dev libncursesw5-dev libreadline-dev libssl-dev libtool lrzsz \
    mkisofs msmtp nano ninja-build p7zip p7zip-full patch pkgconf python2.7 python3 python3-pyelftools \
    libpython3-dev qemu-utils rsync scons squashfs-tools subversion swig texinfo uglifyjs upx-ucl unzip \
    vim wget xmlto xxd zlib1g-dev
# 下面似乎用brew安装的依赖可能不全
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew update && brew upgrade
    brew install gawk gettext libtool automake autoconf wget ncurses openssl
    export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/opt/openssl/lib/
else
    echo "Unsupported operating system"
    exit 1
fi

# 克隆项目到工作目录下的custom目录
echo "克隆 $clone_repo_path 到 $work_dir/custom 目录下"
git clone "$clone_repo_path" "$work_dir/custom"

# 克隆lede到工作目录下的openwrt目录
lede_repo_url="https://github.com/coolsnowwolf/lede.git"
echo "克隆 $lede_repo_url 到 $work_dir/openwrt 目录下"
git clone "$lede_repo_url" "$work_dir/openwrt"

# 复制diy-part*和.config文件到openwrt目录下
cp "$work_dir/custom/diy-part"* "$work_dir/openwrt/"
cp "$work_dir/custom/.config" "$work_dir/openwrt/"

# 给diy-part1.sh和diy-part2.sh脚本赋予执行权限并执行
chmod +x "$work_dir/openwrt/diy-part1.sh"
chmod +x "$work_dir/openwrt/diy-part2.sh"
echo "执行diy-part1.sh脚本"
cd "$work_dir/openwrt" && ./diy-part1.sh

# 更新feed并安装feed
echo "更新feed并安装feed"
./scripts/feeds update -a
./scripts/feeds install -a

# 执行diy-part2.sh脚本
echo "执行diy-part2.sh脚本"
./diy-part2.sh

# 开始编译
echo "执行make defconfig"
make defconfig
echo "执行make download -j8"
make download -j8
# find dl -size -1024c -exec ls -l {} \
# find dl -size -1024c -exec rm -f {} \
make V=s -j$(nproc)
