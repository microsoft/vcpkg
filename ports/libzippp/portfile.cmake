vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF 8299422194ce3c5be0677550ce3d6d4e15d40dd8 #v4.1-1.8.0 with CXX std version c++11
    SHA512 091c744377707899456b027a35059e048e1552e013330c68920f88f94a42904cf1a6afc7f853cf34cc9bbb3956c3c16907f089520e808520a671c59646d5e351
    HEAD_REF master
    PATCHES fix-find-lzma.patch
)

vcpkg_check_features( 
        OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES    
        encryption LIBZIPPP_ENABLE_ENCRYPTION)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBZIPPP_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBZIPPP_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake/libzippp")
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "share/libzippp")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
