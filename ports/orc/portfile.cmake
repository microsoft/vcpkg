vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/orc
  REF "v${VERSION}"
  SHA512 b81e1c2cebfd97757aaaa8dc9bed913810b0a47e599556bc3e9989dadf6b7665c335c37cd29d8430cd9b1af9048f37efaa56869872eb5f50fe35a570ec109a40
  HEAD_REF master
  PATCHES
    external-project.diff
)
file(GLOB modules "${SOURCE_PATH}/cmake_modules/Find*.cmake")

set(orc_format_version 1.1.1)
vcpkg_download_distfile(ORC_FORMAT_ARCHIVE
  URLS "https://dlcdn.apache.org/orc/orc-format-${orc_format_version}/orc-format-${orc_format_version}.tar.gz"
  FILENAME "apache-orc-format-${orc_format_version}.tar.gz"
  SHA512 8aa0bcd3345ed8be836995d4347175526f4b0fc91f41e27f29279fad39b94ff157f5cd597bc2d9f3dc403f5ba405807675a283abe822f8a83758b7c3b8292c1c
)
set(ENV{ORC_FORMAT_URL} "file://${ORC_FORMAT_ARCHIVE}")

if(VCPKG_TARGET_IS_WINDOWS)
  set(BUILD_TOOLS OFF)
  # when cross compiling, we can't run their test. however:
  #  - Windows doesn't support time_t < 0 => HAS_PRE_1970 test returns false
  #  - Windows doesn't support setenv => HAS_POST_2038 test fails to compile
  set(time_t_checks "-DHAS_PRE_1970=OFF" "-DHAS_POST_2038=OFF")
else()
  set(BUILD_TOOLS ON)
  set(time_t_checks "")
endif()

if(VCPKG_TARGET_IS_UWP)
    set(configure_opts WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  ${configure_opts}
  OPTIONS
    ${time_t_checks}
    -DBUILD_TOOLS=${BUILD_TOOLS}
    -DBUILD_CPP_TESTS=OFF
    -DBUILD_JAVA=OFF
    -DINSTALL_VENDORED_LIBS=OFF
    -DBUILD_LIBHDFSPP=OFF
    -DSTOP_BUILD_ON_WARNING=OFF
    -DENABLE_TEST=OFF
    -DORC_PACKAGE_KIND=vcpkg
  MAYBE_UNUSED_VARIABLES
    ENABLE_TEST
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/orc-*)
if(TOOLS)
  file(COPY ${TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/orc")
  file(REMOVE ${TOOLS})
endif()

file(GLOB BINS "${CURRENT_PACKAGES_DIR}/bin/*")
if(NOT BINS)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
