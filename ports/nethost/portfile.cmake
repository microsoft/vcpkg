set(COMMIT_HASH v7.0.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dotnet/runtime
    REF ${COMMIT_HASH}
    SHA512 59210df1d9541018a21a7e89e0f552ad35c849f49be31cf47e2a85086363cdabd2bf8ce652d2024479977ae059d658c3bd18de3bdaeb8cb3ddd71f2413f266bc
    HEAD_REF master
    PATCHES
        0001-nethost-cmakelists.patch
)

set(PRODUCT_VERSION "7.0.0")

if(NOT VCPKG_TARGET_IS_WINDOWS)
  execute_process(COMMAND sh -c "mkdir -p ${SOURCE_PATH}/artifacts/obj && ${SOURCE_PATH}/eng/native/version/copy_version_files.sh")
endif()

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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/src/native/corehost/nethost/"
    # vcpkg's /utf-8 is incompatible with dotnet's own /source-charset:utf-8
    NO_CHARSET_FLAG
    OPTIONS
        "-DSKIP_VERSIONING=1"
        "-DCLI_CMAKE_HOST_POLICY_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_HOST_FXR_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_HOST_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_COMMON_HOST_VER:STRING=${PRODUCT_VERSION}"
        "-DCLI_CMAKE_PKG_RID:STRING=${BASE_RID}"
        "-DCLI_CMAKE_COMMIT_HASH:STRING=${COMMIT_HASH}"
        "-DCLR_CMAKE_TARGET_ARCH_${ARCH_NAME}=1"
        "-DCLR_CMAKE_TARGET_ARCH=${RID_ARCH}"
        "-DCLR_CMAKE_HOST_ARCH=${RID_ARCH}"
    MAYBE_UNUSED_VARIABLES
        SKIP_VERSIONING # only used on WIN32
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-nethost)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/nethost.h" "#ifdef NETHOST_USE_AS_STATIC" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/nethost.h" "#ifdef NETHOST_USE_AS_STATIC" "#if 0")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
