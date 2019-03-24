Release {

# 作者：GPBeta（https://github.com/GPBeta）
# 修改日期：2019-02-14
#
#
# VC-LTL自动化加载配置，建议你将此文件单独复制到你的工程再使用，该文件能自动识别当前环境是否存在VC-LTL，并且自动应用。
#
# 使用方法：
#   1. 在自己的pro文件中添加“include("VC-LTL helper for qmake.pri")”。
#   2. 务必保证所有依赖的静态库也均用VC-LTL重新编译。
#
# VC-LTL默认搜索顺序
#   1. VC-LTL helper for qmake.pri所在目录，即 $$PWD
#   2. VC-LTL helper for qmake.pri所在根目录下的VC-LTL目录，即 $$PWD/VC-LTL
#   3. VC-LTL helper for qmake.pri所在父目录，即$$PWD/..
#   4. 工程文件(*.pro)所在目录，即 $$_PRO_FILE_PWD_
#   5. 工程文件(*.pro)所在根目录下的VC-LTL目录，即，即 $$_PRO_FILE_PWD_/..
#   6. 注册表HKEY_CURRENT_USER\Code\VC-LTL@Root
#
# 把VC-LTL放在其中一个位置即可，VC-LTL就能被自动引用。
#
# 如果你对默认搜索顺序不满，你可以修改此文件。你也可以直接指定VC_LTL_Root环境变量更加任性的去加载VC-LTL。
#




#  ---------------------------------------------------------------------VC-LTL设置---------------------------------------------------------------------

# 取消下方注释可以开启VC-LTL轻量模式，轻量模式更加注重体积控制，但是CRT规范将会维持在VS2008。如果你需要高度兼容微软UCRT，那么请不要打开此选项！！！
# DisableAdvancedSupport = true

# 取消下方注释可以开启强制XP兼容模式，默认情况下仅在选择WinXP工具集时才开启。
# SupportWinXP = true

# -----------------------------------------------------------------------------------------------------------------------------------------------------


!isEmpty(VC_LTL_Root) {
# pri文件根目录存在VC-LTL？
} else:exists($$PWD/_msvcrt.h) {
    VC_LTL_Root = $$PWD
# pri文件根目录下存在VC-LTL？
} else:exists($$PWD/VC-LTL/_msvcrt.h) {
    VC_LTL_Root = $$PWD/VC-LTL
# pri文件父目录存在VC-LTL？
} else:exists($$PWD/../_msvcrt.h) {
    VC_LTL_Root = $$PWD/..
# pri文件父目录存在VC-LTL？
} else:exists($$PWD/../VC-LTL/_msvcrt.h) {
    VC_LTL_Root = $$PWD/../VC-LTL
# pro文件根目录下存在VC-LTL？
} else:exists($$_PRO_FILE_PWD_/VC-LTL/_msvcrt.h) {
    VC_LTL_Root = $$_PRO_FILE_PWD_/VC-LTL
# pro文件父目录存在VC-LTL？
} else:exists($$_PRO_FILE_PWD_/../VC-LTL/_msvcrt.h) {
    VC_LTL_Root = $$_PRO_FILE_PWD_/../VC-LTL
# 读取注册表 HKCU\Code\VC-LTL@Root
} else:greaterThan(QT_VERSION, 5.12.0) {
    VC_LTL_Root = $$read_registry(HKCU, Code\\VC-LTL\\Root)
# QT版本过低，读注册表只能采用reg query
} else {
    VC_LTL_Root = $$quote($$system(reg query HKCU\\Code\\VC-LTL /v Root))
	VC_LTL_Root ~= s/.*(\\w:.*)/\\1
	VC_LTL_Root = $$replace(VC_LTL_Root, \r, "")
    VC_LTL_Root = $$replace(VC_LTL_Root, \n, "")
}

!isEmpty(VC_LTL_Root): include($$VC_LTL_Root/config/config.pri)

}
