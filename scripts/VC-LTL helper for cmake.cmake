cmake_minimum_required(VERSION 3.5.2)

#
#  VC-LTL自动化加载配置，建议你将此文件单独复制到你的工程再使用，该文件能自动识别当前环境是否存在VC-LTL，并且自动应用。
#
#  使用方法：
#    1. 在“CMakeLists.txt” 添加 “include("VC-LTL helper for cmake.cmake")”。
#    2. 务必保证所有依赖的静态库也均用VC-LTL重新编译。
#
#  VC-LTL默认搜索顺序
#    1. “VC-LTL helper for cmake.cmake”所在根目录，即 ${CMAKE_CURRENT_LIST_DIR}
#    2. 当前CMake根目录，即 ${CMAKE_CURRENT_SOURCE_DIR}/VC-LTL
#    3. 当前项目根目录，即 ${PROJECT_SOURCE_DIR}/VC-LTL
#    4. 当前CMake父目录，即 ${CMAKE_CURRENT_SOURCE_DIR}/../VC-LTL
#    5. 当前项目根目录，即 ${PROJECT_SOURCE_DIR}/../VC-LTL
#    6. 注册表HKEY_CURRENT_USER\Code\VC-LTL@Root
#
#  把VC-LTL放在其中一个位置即可，VC-LTL就能被自动引用。
# 
#  如果你对默认搜索顺序不满，你可以修改此文件。你也可以直接指定${VC_LTL_Root}宏更加任性的去加载VC-LTL。
#




#####################################################################VC-LTL设置#####################################################################

#取消下方注释可以开启XP兼容模式，默认才用Vista兼容模式。
#set(SupportWinXP "true")

#取消下方注释可以开启VC-LTL轻量模式，轻量模式更加注重体积控制，但是CRT规范将会维持在VS2008。如果你需要高度兼容微软UCRT，那么请不要打开此选项！！！
#set(DisableAdvancedSupport "true")

####################################################################################################################################################

if(NOT VC_LTL_Root)
	if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/_msvcrt.h)
		set(VC_LTL_Root ${CMAKE_CURRENT_LIST_DIR})
	endif()
endif()

if(NOT VC_LTL_Root)
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/VC-LTL/_msvcrt.h)
		set(VC_LTL_Root ${CMAKE_CURRENT_SOURCE_DIR}/VC-LTL)
	endif()
endif()

if(NOT VC_LTL_Root)
	if(EXISTS ${PROJECT_SOURCE_DIR}/VC-LTL/_msvcrt.h)
        set(VC_LTL_Root ${PROJECT_SOURCE_DIR}/VC-LTL)
    endif()
endif()

if(NOT VC_LTL_Root)
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../VC-LTL/_msvcrt.h)
        set(VC_LTL_Root ${CMAKE_CURRENT_SOURCE_DIR}/../VC-LTL)
    endif()
endif()

if(NOT VC_LTL_Root)
	if(EXISTS ${PROJECT_SOURCE_DIR}/../VC-LTL/_msvcrt.h)
        set(VC_LTL_Root ${PROJECT_SOURCE_DIR}/../VC-LTL)
    endif()
endif()

if(NOT VC_LTL_Root)
    GET_FILENAME_COMPONENT(FOUND_FILE "[HKEY_CURRENT_USER\\Code\\VC-LTL;Root]" ABSOLUTE)
    if (NOT ${FOUND_FILE} STREQUAL "registry")
        set(VC_LTL_Root ${FOUND_FILE})
    endif()
endif()

if(VC_LTL_Root)
    include("${VC_LTL_Root}/config/config.cmake")
endif()
