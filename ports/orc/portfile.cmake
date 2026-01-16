vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF "v${VERSION}"
    SHA512 43353b3c2ac752b388518de017ae9363f45088b9abe995ec0d740575c2b8514b14e0aca36454aab7cbb9d8adf7c93be188317a5997d8931b8ecf9f0a81a59553
    HEAD_REF main
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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   BUILD_TOOLS
)

if(VCPKG_TARGET_IS_WINDOWS)
  list(APPEND FEATURE_OPTIONS "-DHAS_PRE_1970=OFF" "-DHAS_POST_2038=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
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
