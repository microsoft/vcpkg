if (EXISTS ${CURRENT_INSTALLED_DIR}/include/msgpack/pack.h)
    message(FATAL_ERROR "Cannot install ${PORT} when rest-rpc is already installed, please remove rest-rpc using \"./vcpkg remove rest-rpc:${TARGET_TRIPLET}\"")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msgpack/msgpack-c
    REF cpp-6.1.1
    SHA512 6a3df977e7a9c8b50feb7c88cff7a78814d1d41d2f7a657dd37d6cfcfe24f44746f40a6dd46bd5dba7ea59d94b9e40c2baa62c08d9b02168ac93c58cbff3becc
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
