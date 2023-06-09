vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF 1934adf591ffe2a53e48d46a522b222b9c1df870 #v6.1-1.9.2 with CXX std version c++11
    SHA512 1fcc30b5e94c7b7d4bfcd520e91f8cff3d00feeda9acd280ccefa13986aeb98884f45af44334c965a0b6c33a9300f0757d727ff15b86a98e66dd7bf3179c042a
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
