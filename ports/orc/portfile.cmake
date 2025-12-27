vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/orc
  REF "v${VERSION}"
  SHA512 b81e1c2cebfd97757aaaa8dc9bed913810b0a47e599556bc3e9989dadf6b7665c335c37cd29d8430cd9b1af9048f37efaa56869872eb5f50fe35a570ec109a40
  HEAD_REF master
  PATCHES
    external-project.diff
    tools-build.diff
)
file(GLOB modules "${SOURCE_PATH}/cmake_modules/Find*.cmake")
file(REMOVE ${modules} "${SOURCE_PATH}/c++/libs/libhdfspp/libhdfspp.tar.gz")

set(orc_format_version 1.1.1)
vcpkg_download_distfile(ORC_FORMAT_ARCHIVE
  URLS "https://dlcdn.apache.org/orc/orc-format-${orc_format_version}/orc-format-${orc_format_version}.tar.gz"
  FILENAME "apache-orc-format-${orc_format_version}.tar.gz"
  SHA512 8aa0bcd3345ed8be836995d4347175526f4b0fc91f41e27f29279fad39b94ff157f5cd597bc2d9f3dc403f5ba405807675a283abe822f8a83758b7c3b8292c1c
)
set(ENV{ORC_FORMAT_URL} "file://${ORC_FORMAT_ARCHIVE}")

vcpkg_check_features(OUT_FEATURE_OPTIONS options
  FEATURES
    tools   BUILD_TOOLS
)

if(VCPKG_TARGET_IS_WINDOWS)
  list(APPEND options "-DHAS_PRE_1970=OFF" "-DHAS_POST_2038=OFF")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${options}
    -DBUILD_CPP_TESTS=OFF
    -DBUILD_JAVA=OFF
    -DINSTALL_VENDORED_LIBS=OFF
    -DORC_PACKAGE_KIND=vcpkg
    -DSTOP_BUILD_ON_WARNING=OFF
  OPTIONS_DEBUG
    -DBUILD_TOOLS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES csv-import orc-contents orc-memory orc-metadata orc-scan orc-statistics timezone-dump AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/NOTICE" "${SOURCE_PATH}/LICENSE")
