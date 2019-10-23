include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dotnet/core-setup
    REF v3.0.0
    SHA512 667768a3fc11dbe72c7f4f6b3b5431dd898a1731294a3c134c9b2914ea7f5a309a06289e1dddd74736ac775d52f2f366e7f1986edc5cf8b7a0bc2ae5a437063a
    HEAD_REF release/3.0.0
    PATCHES
        0001-nethost-cmakelists.patch
        0002-settings-cmake.patch
)

set(PRODUCT_VERSION "3.0.0")
set(COMMIT_HASH "vcpkg release/3.0.0")

if(VCPKG_TARGET_IS_WINDOWS)
  set(RID_PLAT "win")
elseif(VCPKG_TARGET_IS_OSX)
  set(RID_PLAT "osx")
elseif(VCPKG_TARGET_IS_LINUX)
  set(RID_PLAT "linux")
else()
  message(FATAL_ERROR "Unsupported platform")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(RID_ARCH "x86")
  set(ARCH_NAME "I386")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(RID_ARCH "x64")
  set(ARCH_NAME "AMD64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(RID_ARCH "arm")
  set(ARCH_NAME "ARM")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(RID_ARCH "arm64")
  set(ARCH_NAME "ARM64")
else()
  message(FATAL_ERROR "Unsupported architecture")
endif()

set(BASE_RID "${RID_PLAT}-${RID_ARCH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src/corehost/cli/nethost
    PREFER_NINJA
    OPTIONS
        "-DSKIP_VERSIONING=1"
        "-DCLI_CMAKE_HOST_POLICY_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_HOST_FXR_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_HOST_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_COMMON_HOST_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_PKG_RID:STRING=${BASE_RID}"
        "-DCLI_CMAKE_COMMIT_HASH:STRING=${COMMIT_HASH}"
        "-DCLI_CMAKE_PLATFORM_ARCH_${ARCH_NAME}=1"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/include ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
