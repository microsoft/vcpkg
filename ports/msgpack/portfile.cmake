if (EXISTS ${CURRENT_INSTALLED_DIR}/include/msgpack/pack.h)
    message(FATAL_ERROR "Cannot install ${PORT} when rest-rpc is already installed, please remove rest-rpc using \"./vcpkg remove rest-rpc:${TARGET_TRIPLET}\"")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO msgpack/msgpack-c
    REF cpp-3.3.0
    SHA512 33ed87b23d776cadcc230666e6435088e402c5813e7e4dce5ce79c8c3aceba5a36db8f395278042c6ac44c474b33018ff1635889d8b20bc41c5f6f1d1c963cae
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

vcpkg_fixup_pkgconfig()
