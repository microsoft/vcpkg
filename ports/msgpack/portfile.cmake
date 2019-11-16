include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msgpack/msgpack-c
    REF cpp-3.2.0
    SHA512 698fcdd5b427373997d0c89ff2cd09c44cf3b165defd381ff3cd9e14ecb83841064754a42aab99441a3b17aa26e3daec8f83e40d6d482c4b443b21b313278d14
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(MSGPACK_ENABLE_SHARED OFF)
    set(MSGPACK_ENABLE_STATIC ON)
else()
    set(MSGPACK_ENABLE_SHARED ON)
    set(MSGPACK_ENABLE_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DMSGPACK_ENABLE_SHARED=${MSGPACK_ENABLE_SHARED}
        -DMSGPACK_ENABLE_STATIC=${MSGPACK_ENABLE_STATIC}
        -DMSGPACK_BUILD_EXAMPLES=OFF
        -DMSGPACK_BUILD_TESTS=OFF)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/msgpack)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/msgpack)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/msgpack/COPYING ${CURRENT_PACKAGES_DIR}/share/msgpack/copyright)
