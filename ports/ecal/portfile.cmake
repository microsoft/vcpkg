if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/ecal
    REF "v6.0.1"
    SHA512 c7743990b444fa982ef6df9b35816074cae1067ee671d9ffd5ee16fd25769dce09b2a09fb35e0fd759948b88857de8d6a1d8b6fa8ab4173651c3faeab854e0c4
    HEAD_REF master
    PATCHES
        #0001-disable-app-plugins.patch
        #0002-fix-build.patch
        #0003-fix-dependencies.patch
        #0004-install-cmake-files-to-share.patch
        #0005-remove-install-prefix-macro-value.patch
        #0006-use-find_dependency-in-cmake-config.patch
        #0007-allow-static-build-of-core.patch
        #0008-protobuf-linkage.patch
)

# ====== 修复安装路径 ======
# 修复 1: 主 CMakeLists.txt
file(READ "${SOURCE_PATH}/CMakeLists.txt" ECAL_CMAKE_CONTENT)
string(REPLACE
    "set(eCAL_install_cmake_dir         \${CMAKE_INSTALL_LIBDIR}/cmake/eCAL)"
    "set(eCAL_install_cmake_dir         share/eCAL)"
    ECAL_CMAKE_CONTENT "${ECAL_CMAKE_CONTENT}"
)
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${ECAL_CMAKE_CONTENT}")
 # 修复 2: 内部 CMakeFunctions 文件 (使用你提供的最新代码进行匹配)
file(READ "${SOURCE_PATH}/thirdparty/cmakefunctions/cmake_functions/CMakeLists.txt" CMAKE_FUNCTIONS_CONTENT)
string(REPLACE
[[if (MSVC)
# Variable definitions
set(cmake_functions_install_cmake_dir   cmake)
else (MSVC)
set(cmake_functions_install_cmake_dir   "\${CMAKE_INSTALL_LIBDIR}/cmake/\${PROJECT_NAME}-\${PROJECT_VERSION}")
endif (MSVC)]]
[[set(cmake_functions_install_cmake_dir "share/\${PROJECT_NAME}")]]
    CMAKE_FUNCTIONS_CONTENT "${CMAKE_FUNCTIONS_CONTENT}"
)
file(WRITE "${SOURCE_PATH}/thirdparty/cmakefunctions/cmake_functions/CMakeLists.txt" "${CMAKE_FUNCTIONS_CONTENT}")

file(WRITE "${SOURCE_PATH}/thirdparty/cmakefunctions/cmake_functions/CMakeLists.txt" "${CMAKE_FUNCTIONS_CONTENT}")
# ====== 修复结束 ======

# 明确设置Ninja路径，解决CMake找不到的问题
set(CMAKE_MAKE_PROGRAM "C:/Users/34035/vcpkg/downloads/tools/ninja-1.13.2-windows/ninja.exe")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHAS_HDF5=ON
        -DHAS_QT5=OFF
        -DHAS_CURL=OFF
        -DHAS_CAPNPROTO=OFF
        -DHAS_FTXUI=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_APPS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_TIME=OFF
        -DBUILD_PY_BINDING=OFF
        -DBUILD_CSHARP_BINDING=OFF
        -DBUILD_ECAL_TESTS=OFF
        -DECAL_USE_QT=OFF
        -DECAL_INCLUDE_PY_SAMPLES=OFF
        -DECAL_INSTALL_SAMPLE_SOURCES=OFF
        -DECAL_NPCAP_SUPPORT=OFF
        -DECAL_THIRDPARTY_BUILD_CMAKE_FUNCTIONS=ON
        -DECAL_THIRDPARTY_BUILD_SPDLOG=OFF
        -DECAL_THIRDPARTY_BUILD_TINYXML2=OFF
        -DECAL_THIRDPARTY_BUILD_FINEFTP=OFF
        -DECAL_THIRDPARTY_BUILD_TERMCOLOR=OFF
        -DECAL_THIRDPARTY_BUILD_TCP_PUBSUB=OFF
        -DECAL_THIRDPARTY_BUILD_RECYCLE=OFF
        -DECAL_THIRDPARTY_BUILD_FTXUI=OFF
        -DECAL_THIRDPARTY_BUILD_GTEST=OFF
        -DECAL_THIRDPARTY_BUILD_UDPCAP=OFF
        -DECAL_THIRDPARTY_BUILD_PROTOBUF=OFF
        -DECAL_THIRDPARTY_BUILD_YAML-CPP=OFF
        -DECAL_THIRDPARTY_BUILD_CURL=OFF
        -DECAL_THIRDPARTY_BUILD_HDF5=OFF
        -DCPACK_PACK_WITH_INNOSETUP=OFF
        -DECAL_BUILD_VERSION="${VERSION}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME eCAL           CONFIG_PATH share/eCAL)
vcpkg_cmake_config_fixup(PACKAGE_NAME CMakeFunctions CONFIG_PATH share/CMakeFunctions)

# Remove extra debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# global ini files not strictly required
if (VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cfg" "${CURRENT_PACKAGES_DIR}/debug/cfg")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc" "${CURRENT_PACKAGES_DIR}/debug/etc")
endif()

# Install copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
