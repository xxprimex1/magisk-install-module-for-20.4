本次我上传的模版**支持magisk最新的20.4**，模版是**最新的**，**基于topjohnwu的部分脚本和历史模版改编**而成。

如何使用，模版里面的各项文件**都有中文说明**，**20.4**经过测试在**19.3**也可以使用，前提是**您脚本相关地方设置的最低刷入版本**

**特别**的我说一下：

**我采用了install.sh的安装方法，因此如果您想使用customize.sh，请自行编写相应脚本，并删除install.sh**



## **magisk20.4模版.zip/install.sh中**，

1、请根据您的需要自行修改**true**和**false**，**SKIPMOUNT一般为false**，install.sh中都有说明

`SKIPMOUNT=false`

`PROPFILE=false`

`POSTFSDATA=false`

`LATESTARTSERVICE=false`

2、请在这里添加您要替换的目录或文件，请**不要**在`REPLACE_EXAMPLE=`上添加您需要替换的目录或文件

`REPLACE="`
`"`

3、on_install我放在了这里，并在on_install下面我又写了一遍**函数名**，**这是为了在执行install.sh后复制magisk20.4模版.zip/system下的所有文件复制到 $MODPATH下**

`on_install(){`

<!--以下是默认实现：将$ZIPFILE/system提取到$MODPATH-->

`ui_print "- 提取模块文件"`
`unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2`
`}`

`on_install`

4、剩下的就是您**自定义的脚本内容**了，请记住，**没有print_modname函数**，所以您需要**自行使用ui_print来打印模块名字**。

## **magisk20.4模版.zip/module.prop中**，

`id=模块ID
name=模块名称
version=模块版本
versionCode=模块版本号
author=模块作者
description=模块描述
minMagisk=20300`

相关说明已写好，`minMagisk`表示**模块支持的最低magisk版本**，**请与update-binary中一致**



## **magisk20.4模版.zip/system中，请自建**

这个文件夹是直接替换system的，不需要用户同意，当然也是挂载，复制到$MODPATH/system，也就是上文on_install的作用



## **magisk20.4模版.zip/common中,包含**



**system.prop，post-fs-data.sh，service.sh**



**magisk20.4模版.zip/META-INF\com\google\android中**,包含**updater-script**和**update-binary**

**updater-script**中可以为**空**，也可以由**您自行使用# 来说明**



## **update-binary**我做了一些调整，具体如下：

1、20.4启用`TMPDIR`，并不是17中的`INSTALLER`

`TMPDIR=/dev/tmp`
`PERSISTDIR=/sbin/.magisk/mirror/persist`

2、`require_new_magisk`这里的文案，请根据`/data/adb/magisk/util_functions.sh`中的`MAGISK_VER_CODE`进行修改

`require_new_magisk() {`
  `ui_print "*******************************"`
  `ui_print " 请安装 Magisk v20.4+! "`
  `ui_print "*******************************"`
  `exit 1`
`}`

3、**对install.sh生效**，这儿是对**install.sh相关文件**的设置权限，如果您需要**设置权限**并且**使用的是install.sh**，请在这里添加。

`set_permissions() {`

`默认权限`

`只有一些特殊文件需要特定的权限`

`默认的权限应该适用于大多数情况`

`下面是 set_perm 函数的一些示例:`

`set_perm_recursive  <目录> <所有者> <用户组> <目录权限> <文件权限> <上下文> `

`(上下文默认值是:u:object_r:system_file:s0)`

`set_perm_recursive  $MODPATH/system/lib       0       0       0755        0644`

`set_perm  <文件名> <所有者> <用户组> <文件权限> <上下文> (默认值是:u:object_r:system_file:s0)`

`set_perm  $MODPATH/system/bin/app_process32 0 2000 0755 u:object_r:zygote_exec:s0`

`set_perm  $MODPATH/system/bin/dex2oat 0 2000 0755 u:object_r:dex2oat_exec:s0`

`set_perm  $MODPATH/system/lib/libart.so       0       0         0644`

`以下是默认权限，请勿删除`

```shell
set_perm_recursive $MODPATH 0 0 0755 0644
```

`}`

4、此处就是上文所说的`MAGISK_VER_CODE`，对应**第2点**。请与**module.prop**中**minMagisk**的设置及第2点的**ui_print部分**保持一致有助于用户理解和自己的修改

`[ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk`
`. /data/adb/magisk/util_functions.sh`
`[ $MAGISK_VER_CODE -gt 20300 ] || require_new_magisk`

5、此处我修改-oj为-o，有助于模块作者添加自己的文件及更好的检查脚本错误

**unzip -o "$ZIPFILE" module.prop -d $TMPDIR >&2**
**[ ! -f $TMPDIR/module.prop ] && abort "! 从 zip 中提取文件失败!"**

举例：模版/common/system.prop

使用**-oj**将会解压到**/dev/tmp/system.prop**

使用**-o**将会解压到**/dev/tmp/common/system.prop**

6、此处**原版为-oj**，**我修改为了-o**，原因同上，在此，您也应该看到了，**模块解压目录是在$TMPDIR**，**请不要使用17中的$INSTALLER**。所以由此您也看出来了，**system.prop，post-fs-data.sh，service.sh**应该在**模版/common下**

  `unzip -o "$ZIPFILE" module.prop install.sh uninstall.sh 'common/*' -d $TMPDIR >&2`

`加载安装脚本`

  `. $TMPDIR/install.sh`

`Custom 卸载程序`

  `[ -f $TMPDIR/uninstall.sh ] && cp -af $TMPDIR/uninstall.sh $MODPATH/uninstall.sh`

`取消挂载`

  `$SKIPMOUNT && touch $MODPATH/skip_mount`

`prop 文件`

  `$PROPFILE && cp -af $TMPDIR/common/system.prop $MODPATH/system.prop`

`模块信息`

  `cp -af $TMPDIR/module.prop $MODPATH/module.prop`

`post-fs-data 模式脚本`

  `$POSTFSDATA && cp -af $TMPDIR/common/post-fs-data.sh $MODPATH/post-fs-data.sh`

`service 模式脚本`

  `$LATESTARTSERVICE && cp -af $TMPDIR/common/service.sh $MODPATH/service.sh`

7、此处就是第3点所提到的**对install.sh生效**的**设置权限**，如果**您需要且使用install.sh**，您应该在这里设置

`<!--设置权限-->`

`ui_print "- 正在设置权限，这需要一点时间，请坐和放宽"`

`ui_print "- 不要着急，在干活啦"`

`set_permissions`

8、这里是**customize.sh的相关部分**，如果您**使用install.sh**，请**不要再使用install.sh**，因为会**优先使用install.sh**，而不是**customize.sh**，并且，由于**模版不涉及**，所以**删除了`print_modname`**，所以如果您需要**customize.sh**，请在**update-binary相关位置插入如下的函数**，

`print_modname(){`

`}`

**插入后**，你就不需要在**customize.sh**中再次使用ui_print打印模块名字

 `print_modname`

  `unzip -o "$ZIPFILE" customize.sh -d $MODPATH >&2`

  `if ! grep -q '^SKIPUNZIP=1$' $MODPATH/customize.sh 2>/dev/null; then`
    `ui_print "- 正在提取模块文件"`
    `unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2`

`默认权限`

`只有一些特殊文件需要特定的权限-->`

`默认的权限应该适用于大多数情况`

`下面是 set_perm 函数的一些示例:`

`set_perm_recursive <目录> <所有者> <用户组> <目录权限> <文件权限> <上下文> `

`(上下文默认值是:u:object_r:system_file:s0)`

`set_perm_recursive  $MODPATH/system/lib 0 0 0755 0644`

`set_perm <文件名> <所有者> <用户组> <文件权限> <上下文> (默认值是: u:object_r:system_file:s0)`

`set_perm  $MODPATH/system/bin/app_process32 0 2000 0755 u:object_r:zygote_exec:s0`

`set_perm  $MODPATH/system/bin/dex2oat 0 2000 0755 u:object_r:dex2oat_exec:s0`

`set_perm  $MODPATH/system/lib/libart.so 0 0 0644`

`以下是默认权限，请勿删除`

```shell
set_perm_recursive $MODPATH 0 0 0755 0644
```
  `fi`

`加载 customization 脚本`

  `[ -f $MODPATH/customize.sh ] && . $MODPATH/customize.sh`
`fi`

9、replace部分，经过测试，**20.4**相关文件夹下是空，而老版本依然是**.replace**文件

处理 replace 文件夹

`for TARGET in $REPLACE; do`

`ui_print "- 正在删除目标: $TARGET"`

`mktouch $MODPATH$TARGET/.replace`
`done`

10、Custom sepolicy 规则，这个我也不知道，大家可以使用网络进行查询，需要的请把文件放在下common

`复制 Custom sepolicy 规则`

`if [ -f $MODPATH/sepolicy.rule -a -e $PERSISTDIR ]; then`
  `ui_print "- 安装 Custom sepolicy 补丁"`
  `PERSISTMOD=$PERSISTDIR/magisk/$MODID`
  `mkdir -p $PERSISTMOD`
  `cp -af $MODPATH/sepolicy.rule $PERSISTMOD/sepolicy.rule`
`fi`

以上就是我的magisk20.4模版的介绍，再次强调，**20.4修改minMagisk和MAGISK_VER_CODE后在19.3上依然可用**，**ui_print**部分也请保持一致，方便修改

谢谢大家使用

