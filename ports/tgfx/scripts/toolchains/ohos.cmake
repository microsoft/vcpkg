
# 设置 HarmonyOS 平台标识
set(CMAKE_SYSTEM_NAME OHOS CACHE STRING "")
set(OHOS_PLATFORM OHOS CACHE STRING "")

# 查找鸿蒙NDK路径，支持多种环境变量命名
set(OHOS_SDK_ROOT "")

# 1. 优先使用 OHOS_SDK_HOME 环境变量（推荐）
if(DEFINED ENV{OHOS_SDK_HOME})
    set(OHOS_SDK_ROOT $ENV{OHOS_SDK_HOME})
# 2. 使用 OHOS_NDK_HOME 环境变量
elseif(DEFINED ENV{OHOS_NDK_HOME})
    set(OHOS_SDK_ROOT $ENV{OHOS_NDK_HOME})
# 3. 使用 CMAKE_OHOS_NDK 环境变量（与 JS 工具保持一致）
elseif(DEFINED ENV{CMAKE_OHOS_NDK})
    set(OHOS_SDK_ROOT $ENV{CMAKE_OHOS_NDK})
# 4. 使用 OHOS_SDK 环境变量
elseif(DEFINED ENV{OHOS_SDK})
    set(OHOS_SDK_ROOT $ENV{OHOS_SDK})
# 5. 使用 HARMONY_SDK_HOME 环境变量
elseif(DEFINED ENV{HARMONY_SDK_HOME})
    set(OHOS_SDK_ROOT $ENV{HARMONY_SDK_HOME})
else()
    message(FATAL_ERROR "Could not find OHOS SDK. Please set one of the following environment variables:\n"
                        "  OHOS_SDK_HOME (recommended)\n"
                        "  OHOS_NDK_HOME\n"
                        "  CMAKE_OHOS_NDK\n"
                        "  OHOS_SDK\n"
                        "  HARMONY_SDK_HOME")
endif()

# 验证SDK根目录结构
if(NOT EXISTS "${OHOS_SDK_ROOT}")
    message(FATAL_ERROR "OHOS SDK path does not exist: ${OHOS_SDK_ROOT}")
endif()

# 检查是否包含native子目录
if(NOT EXISTS "${OHOS_SDK_ROOT}/native")
    message(FATAL_ERROR "Invalid OHOS SDK structure. Missing 'native' directory in: ${OHOS_SDK_ROOT}")
endif()

# 设置NDK路径（指向native子目录）
set(OHOS_NDK_HOME "${OHOS_SDK_ROOT}/native")

# 验证 NDK 工具链文件
if(NOT EXISTS "${OHOS_NDK_HOME}/build/cmake/ohos.toolchain.cmake")
    message(FATAL_ERROR "Could not find OHOS toolchain at ${OHOS_NDK_HOME}/build/cmake/ohos.toolchain.cmake")
endif()

# 验证 sysroot 目录
if(NOT EXISTS "${OHOS_NDK_HOME}/sysroot")
    message(FATAL_ERROR "Could not find OHOS sysroot at ${OHOS_NDK_HOME}/sysroot")
endif()

message(STATUS "Using OHOS SDK: ${OHOS_SDK_ROOT}")
message(STATUS "Using OHOS NDK: ${OHOS_NDK_HOME}")


# 根据 vcpkg triplet 设置 OHOS_ARCH（与 JS 工具保持一致的架构命名）
if (VCPKG_TARGET_TRIPLET MATCHES "x64-ohos")
    set(OHOS_ARCH x86_64 CACHE STRING "")
elseif (VCPKG_TARGET_TRIPLET MATCHES "arm64-ohos")
    set(OHOS_ARCH arm64-v8a CACHE STRING "")
elseif(VCPKG_TARGET_TRIPLET MATCHES "arm.*-ohos")
    set(OHOS_ARCH armeabi-v7a CACHE STRING "")
    if(VCPKG_TARGET_TRIPLET MATCHES "arm-neon-ohos")
        set(OHOS_ARM_NEON ON CACHE BOOL "")
    else()
        set(OHOS_ARM_NEON OFF CACHE BOOL "")
    endif()
else()
    message(FATAL_ERROR "Unknown ABI for target triplet ${VCPKG_TARGET_TRIPLET}")
endif()

# 设置环境变量供 OHOS 工具链使用
set(ENV{CMAKE_OHOS_NDK} ${OHOS_NDK_HOME})
set(OHOS_SDK_NATIVE ${OHOS_NDK_HOME} CACHE PATH "")
set(OHOS_SDK_HOME ${OHOS_SDK_ROOT} CACHE PATH "")

# 包含 HarmonyOS NDK 的官方工具链（使用正确的路径）
include("${OHOS_NDK_HOME}/build/cmake/ohos.toolchain.cmake")

if(NOT _VCPKG_OHOS_TOOLCHAIN)
    set(_VCPKG_OHOS_TOOLCHAIN 1)

    if(POLICY CMP0056)
        cmake_policy(SET CMP0056 NEW)
    endif()
    if(POLICY CMP0066)
        cmake_policy(SET CMP0066 NEW)
    endif()
    if(POLICY CMP0067)
        cmake_policy(SET CMP0067 NEW)
    endif()
    if(POLICY CMP0137)
        cmake_policy(SET CMP0137 NEW)
    endif()
    list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
        VCPKG_CRT_LINKAGE VCPKG_TARGET_ARCHITECTURE
        VCPKG_C_FLAGS VCPKG_CXX_FLAGS
        VCPKG_C_FLAGS_DEBUG VCPKG_CXX_FLAGS_DEBUG
        VCPKG_C_FLAGS_RELEASE VCPKG_CXX_FLAGS_RELEASE
        VCPKG_LINKER_FLAGS VCPKG_LINKER_FLAGS_RELEASE VCPKG_LINKER_FLAGS_DEBUG
    )

    string(APPEND CMAKE_C_FLAGS " -fPIC ${VCPKG_C_FLAGS} ")
    string(APPEND CMAKE_CXX_FLAGS " -fPIC ${VCPKG_CXX_FLAGS} ")
    string(APPEND CMAKE_C_FLAGS_DEBUG " ${VCPKG_C_FLAGS_DEBUG} ")
    string(APPEND CMAKE_CXX_FLAGS_DEBUG " ${VCPKG_CXX_FLAGS_DEBUG} ")
    string(APPEND CMAKE_C_FLAGS_RELEASE " ${VCPKG_C_FLAGS_RELEASE} ")
    string(APPEND CMAKE_CXX_FLAGS_RELEASE " ${VCPKG_CXX_FLAGS_RELEASE} ")

    string(APPEND CMAKE_MODULE_LINKER_FLAGS " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS " ${VCPKG_LINKER_FLAGS} ")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG " ${VCPKG_LINKER_FLAGS_DEBUG} ")
    string(APPEND CMAKE_MODULE_LINKER_FLAGS_RELEASE " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE " ${VCPKG_LINKER_FLAGS_RELEASE} ")
endif()
