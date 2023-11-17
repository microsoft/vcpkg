vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dotnet/runtime
    REF "v${VERSION}"
    SHA512 a7de43bb294a62b661dd0b8f832c0ee64a6bd4a13deb4f65f51a8a8407cc5094d25cc703223d916451209284e013775a47da226098569e94694f3762a79e1de2
    HEAD_REF master
    PATCHES
        0001-nethost-cmakelists.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
  execute_process(COMMAND "sh" "-c" "mkdir -p ${SOURCE_PATH}/artifacts/obj && ${SOURCE_PATH}/eng/native/version/copy_version_files.sh")
else()
  execute_process(COMMAND "cmd.exe" "/c" "mkdir artifacts\\obj && eng\\native\\version\\copy_version_files.cmd" WORKING_DIRECTORY "${SOURCE_PATH}")
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
        "-DCLI_CMAKE_PKG_RID:STRING=${BASE_RID}"
        "-DCLI_CMAKE_FALLBACK_OS:STRING=${RID_PLAT}"
        "-DCLI_CMAKE_COMMIT_HASH:STRING=v${VERSION}"
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.TXT")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
