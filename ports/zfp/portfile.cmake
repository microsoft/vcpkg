vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/zfp
    REF 0.5.5
    SHA512 c043cee73f6e972e047452552ab2ceb9247a6747fdb7e5f863aeab3a05208737c0bcabbe29f3c10e5c1aba961ec47aa6a0abdb395486fa0d5fb16a4ad45733c4
    HEAD_REF master
    PATCHES
       fix-build-error.patch
       fix-install-tools.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    all     BUILD_ALL
    cfp     BUILD_CFP
    test    BUILD_TESTING
    example BUILD_EXAMPLES
    utility BUILD_UTILITIES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
      -DBUILD_ZFPY=OFF
      -DBUILD_ZFORP=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

# Rename problematic root include "bitstream.h"; conflicts with x265's private headers
file(RENAME ${CURRENT_PACKAGES_DIR}/include/bitstream.h ${CURRENT_PACKAGES_DIR}/include/zfp/bitstream.h)
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/zfp.h "\"bitstream.h\"" "\"zfp/bitstream.h\"")

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)