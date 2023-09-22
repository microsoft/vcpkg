vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF 7bc5e5d7de8808acd0a00fc2f993bf9141086c22 #v7.0-1.10.1 with CXX std version c++11
    SHA512 f84aaab7ccf3d2f90ed1b49e9d71059c045e8aab08bc185a2d63f2ff6ba106c185e7d8938fe653fe96797e9f4f36fb04c12927a4339250ac431eed01ebf900bb
    HEAD_REF master
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
