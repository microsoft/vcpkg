vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF 0e907d7ef8de46822602cb7633a5bc6fc0cc36de #v5.0-1.8.0 with CXX std version c++11
    SHA512 f91724b0225bddcaf705e7e1493ad415b534096cfe3636d50995245982984e7420148206f4e24d72e596d75eac570d7b512c5aa836eaf4a8951e27737bcee9eb
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
