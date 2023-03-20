if (EXISTS ${CURRENT_INSTALLED_DIR}/include/msgpack/pack.h)
    message(FATAL_ERROR "Cannot install ${PORT} when rest-rpc is already installed, please remove rest-rpc using \"./vcpkg remove rest-rpc:${TARGET_TRIPLET}\"")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msgpack/msgpack-c
    REF cpp-4.1.3
    SHA512 1252a2d61b119e9a8db6cc3667d2ae3234784d6607e2d08b836ab2f561455aa8c14ac134de0e8bb47f85a9fa86a9b325babd0a5a437daa0f270143d07738adcf
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSGPACK_BUILD_EXAMPLES=OFF
        -DMSGPACK_BUILD_TESTS=OFF
        -DMSGPACK_BUILD_DOCS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME msgpackc-cxx CONFIG_PATH lib/cmake/msgpackc-cxx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
