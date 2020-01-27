##########################################################################################
#
# Magisk模块安装脚本
#
##########################################################################################
##########################################################################################
#
# 说明:
#
# 1. 将文件放入系统文件夹
# 2. 第二步在module.prop中填写模块信息
# 3. 如果需要引导脚本，请将它们添加到common/post-fs-data.sh或common/service.sh中
# 4. 将附加或修改的系统属性添加到common/system.prop中
#
##########################################################################################

##########################################################################################
# 配置
##########################################################################################

# 如果您不希望Magisk为您挂载任何文件，请将其设置为true
# 大多数模块不希望将此标志设置为true
SKIPMOUNT=false

# 如果您需要加载system.prop，请将其设置为true
PROPFILE=false

# 如果您需要post-fs-data脚本（post-fs-data.sh），请将其设置为true
POSTFSDATA=false

# 如果您需要late_start服务脚本（service.sh），请将其设置为true
LATESTARTSERVICE=false

##########################################################################################
# 替换列表
##########################################################################################

# 列出您想在系统中直接替换的所有目录

# 按照以下格式构造列表
# 这是一个例子
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# 在这里构建您自己的列表
REPLACE="
"

##########################################################################################
#
# 回调函数
#
# 安装框架将调用以下函数
# 您没有修改update-binary的能力，您定制安装的唯一方法是通过这些函数
#
# 当运行回调时，安装框架将确保Magisk内部busybox路径是*PREPENDED* to path
# 因此所有通用命令都应该存在
# 同时, 它也将确保/data, /system,和/vendor能够正常的被挂载
#
##########################################################################################
##########################################################################################
#
# 安装框架将导出一些变量和函数
# 您应该使用这些变量和函数进行安装
#
# 不要使用任何Magisk内部路径，因为它们不是公共API。
# 不要在util_functions.sh中使用其他函数，因为它们不是公共API。
# 非公共API并不能保证新旧版本之间的兼容性。
#
# 可用变量:
#
# MAGISK_VER (string): 当前安装的Magisk Manager的版本
# MAGISK_VER_CODE (int): 当前安装的Magisk的版本
# BOOTMODE (bool): 如果模块当前安装在Magisk Manager中，则为true
# MODPATH (path): 模块文件的安装路径
# TMPDIR (path): 可以临时存储文件的地方
# ZIPFILE (path): 安装模块的zip文件
# ARCH (string): 设备的架构。值可以是arm、arm64、x86或x64
# IS64BIT (bool): 如果$ARCH是arm64或x64，则为真
# API (int): 设备的API级别(Android版本)
#
# 可用参数:
#
# ui_print "message"
#     打印message到安装界面
#     不要使用"echo"，因为"echo"是recovery下update-binary打印文本的命令
#
# abort "message"
#     打印message到安装界面并终止安装
#     不要使用"exit"，因为它会跳过终止后的清理步骤
#
# set_perm <target> <owner> <group> <permission> [context]
#     如果[context]为空，它将默认为"u:object_r:system_file:s0"
#     这个函数是以下命令的缩写
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     如果[context]为空，它将默认为"u:object_r:system_file:s0
#     对于中的所有文件，它将调用:
#       set_perm file owner group filepermission context
#     对于<directory>中的所有目录（包括它自己），它将调用:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# 如果需要引导脚本，不要使用一般的引导脚本(post-fs-data.sh/service.sh)
# 只使用模块脚本，因为它尊重模块状态(删除或禁用)，并保证在未来的Magisk版本中保持相同的行为。
# 通过在上面的config部分设置标志来启用引导脚本
##########################################################################################

# 只有一些特殊的文件需要特定的权限
# 这个函数将在on_install完成后调用
# 对于大多数情况，默认权限应该足够好

on_install(){
  # 以下是默认实现：将$ZIPFILE/system提取到$MODPATH
  ui_print "- 提取模块文件"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}

on_install
# 您可以添加更多的函数来辅助您的自定义脚本