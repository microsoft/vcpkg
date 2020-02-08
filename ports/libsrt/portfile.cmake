vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Haivision/srt
    REF v1.3.4
    SHA512 3a9f9a8fd8ba56ae9ca04203bdea9e9a25275e1f531ca10deee0e760e6beaf44e83ee7a616cfe3ade9676082d9cc8611214de876f64d141e1e8c3b1e16273001
    HEAD_REF master
    PATCHES fix-dependency-install.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_DYNAMIC ON)
    set(BUILD_STATIC OFF)
else()
    set(BUILD_DYNAMIC OFF)
    set(BUILD_STATIC ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tool ENABLE_APPS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
        -DENABLE_SHARED=${BUILD_DYNAMIC}
        -DENABLE_STATIC=${BUILD_STATIC}
        -DINSTALL_DOCS=ON
        -DINSTALL_PKG_CONFIG_MODULE=ON
        -DENABLE_SUFLIP=OFF # Since there are some file not found, disable this feature
        -DENABLE_UNITTESTS=OFF
        -DUSE_OPENSSL_PC=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)