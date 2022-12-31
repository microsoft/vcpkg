vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF 681bac0362b82bba8f28117d8a48dca54f028ee5 #v6.0-1.9.2 with CXX std version c++11
    SHA512 2f9ab671de2af0e97d5b3fe4f367504ad47f2e1f6df8009aec8e96680f34bf0e3ae5b45ebaea846676b2527d0a5fd31d91c6f62a2bba2867c6010a387ff24150
    HEAD_REF master
    PATCHES fix-find-lzma.patch
)

vcpkg_check_features( 
        OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES    
        encryption LIBZIPPP_ENABLE_ENCRYPTION)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBZIPPP_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBZIPPP_INSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH "cmake/libzippp")
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "share/libzippp")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
