if (EXISTS ${CURRENT_INSTALLED_DIR}/include/msgpack/pack.h)
    message(FATAL_ERROR "Cannot install ${PORT} when rest-rpc is already installed, please remove rest-rpc using \"./vcpkg remove rest-rpc:${TARGET_TRIPLET}\"")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msgpack/msgpack-c
    REF cpp-${VERSION}
    SHA512 2501fc1ec9a52614ae86210545ecc8ae4b36e055018cd6bfca6543503d3c17b6a84e464c9136c881fb32bc6464cea5b38c7cc2c44c84c173f67a612cc220a2c6
    HEAD_REF cpp_master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        boost MSGPACK_USE_BOOST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSGPACK_BUILD_EXAMPLES=OFF
        -DMSGPACK_BUILD_TESTS=OFF
        -DMSGPACK_BUILD_DOCS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME msgpack-cxx CONFIG_PATH lib/cmake/msgpack-cxx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
