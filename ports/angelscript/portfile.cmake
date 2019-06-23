include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.angelcode.com/angelscript/sdk/files/angelscript_2.33.0.zip"
    FILENAME "angelscript_2.33.0.zip"
    SHA512 eaf972ecf965fe4f72e55755f5e796499018e918f93cfd835b1ca20f9338e299e8dbd707240341eef81ae920f07d2280646151f515f5990a62550689445c86f0
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
       mark-threads-private.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/angelscript/projects/cmake
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Angelscript)

# Handle copyright
file(INSTALL ${CURRENT_PORT_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/angelscript RENAME copyright)
