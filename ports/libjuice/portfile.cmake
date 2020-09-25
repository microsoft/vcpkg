vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF v0.4.6
    SHA512 621756116f36a0506fa2755d8baf4df2908a1b2955fe8fab60d5c2f58a5b98389dd5518acc4ab9b998b6f7c1499a19796ddf11eda320473b2c81f69353b05a8f
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    nettle USE_NETTLE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(FILE "${SOURCE_PATH}/CMakeLists.txt")
    file(READ ${FILE} _contents)
    string(REPLACE "add_library(juice SHARED" "add_library(juice STATIC" _contents "${_contents}")
    file(WRITE ${FILE} "${_contents}")
endif()

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/libjuice)
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
