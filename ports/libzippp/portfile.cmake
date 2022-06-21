vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF 4248d7bf200e00b637cbd394c2b2369891de4e30 #v5.1-1.8.0 with CXX std version c++11
    SHA512 171010da61ab4893648ceef80009925e7b79294008de220fe132c42843cb939e454812c0e70de29dfb0318e6bf11c7924a31da52f7703c523ab95c68ba61051a
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
