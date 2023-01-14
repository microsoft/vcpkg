if (WIN32)
    set(PATCHES fix-POSIX_name.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yaml/libyaml
    REF 2c891fc7a770e8ba2fec34fc6b545c672beb37e6 # 0.2.5
    SHA512 7cdde7b48c937777b851747f7e0b9a74cb7da30173e09305dad931ef83c3fcee3e125e721166690fe6a0987ba897564500530e5518e4b66b1c9b1db8900bf320
    HEAD_REF master
    PATCHES
        ${PATCHES}
        export-pkgconfig.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DINSTALL_CMAKE_DIR=share/yaml
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME yaml CONFIG_PATH share/yaml)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/config.h" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/License" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
