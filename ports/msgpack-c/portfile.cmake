if (EXISTS ${CURRENT_INSTALLED_DIR}/include/msgpack/pack.h)
    message(FATAL_ERROR "Cannot install ${PORT} when rest-rpc is already installed, please remove rest-rpc using \"./vcpkg remove rest-rpc:${TARGET_TRIPLET}\"")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msgpack/msgpack-c
    REF "c-${VERSION}"
    SHA512 b211af122e894bc0c32fa02ebcc0130ac797d99b7c60688df26247bc020d51b7322b4858fd12a749d28812c5efb66b5dc687cdfe20f4bc68a21eb484d531230a
    HEAD_REF c_master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSGPACK_BUILD_EXAMPLES=OFF
        -DMSGPACK_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME msgpack-c CONFIG_PATH lib/cmake/msgpack-c)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
