include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msgpack/msgpack-c
    REF cpp-2.1.5
    SHA512 aab8357e494bb5aa7407b53e5e650382869ea95812a6677e085530d5f27cde6946fbfd0095b19608c75163dbb82de9ccb6a695234e7c03659fc6efc2da300e19
    HEAD_REF master)

vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-static-lib-option.patch)

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
