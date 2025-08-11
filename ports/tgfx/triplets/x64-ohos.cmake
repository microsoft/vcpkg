set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME OHOS)
set(VCPKG_CMAKE_SYSTEM_VERSION 17)

# 设置工具链文件路径
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../scripts/toolchains/ohos.cmake")

# 设置环境变量检查
if(NOT DEFINED ENV{OHOS_NDK_HOME})
    message(FATAL_ERROR "Please set OHOS_NDK_HOME environment variable to point to your HarmonyOS NDK installation")
endif()