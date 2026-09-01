string(REGEX REPLACE "^([0-9]+)[.]([1-9])\$" "\\1.0\\2" MEDIAINFO_VERSION "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MediaArea/MediaInfoLib
    REF "v${MEDIAINFO_VERSION}"
    SHA512 31ceaeb9495443c5e87013474d43b1a3f98a5c9d7b203ddc1fafefde623dfa8318a0569f8cd627251b8fb525540eb411f8cd018c1cae113290609c6b09b6b8c8
    HEAD_REF master
    PATCHES
        dependencies.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/Source/ThirdParty/tinyxml2")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        curl    VCPKG_LOCK_FIND_PACKAGE_CURL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/Project/CMake"
    OPTIONS
        ${options}
        -DBUILD_ZENLIB=0
        -DBUILD_ZLIB=0
        -DCMAKE_REQUIRE_FIND_PACKAGE_PkgConfig=1
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME mediainfolib)
vcpkg_fixup_pkgconfig()
if(NOT VCPKG_BUILD_TYPE AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libmediainfo.pc" " -lmediainfo" " -lmediainfod")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
