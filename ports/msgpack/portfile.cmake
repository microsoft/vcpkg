include(vcpkg_common_functions)

set(MSGPACK_VERSION 2.1.1)
set(MSGPACK_HASH 31ed6fda498d43da6fdbbe000ce36c40e4cf886f00d879c57d406def7f5bba4eaf66f02f221398cb50f6f4c748d5cde9c97eca0cfa21b368c7c933c3301cf9b5)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/msgpack-${MSGPACK_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/msgpack/msgpack-c/releases/download/cpp-${MSGPACK_VERSION}/msgpack-${MSGPACK_VERSION}.tar.gz"
    FILENAME "msgpack-${MSGPACK_VERSION}.tar.gz"
    SHA512 ${MSGPACK_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(MSGPACK_ENABLE_SHARED OFF)
else()
    set(MSGPACK_ENABLE_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DMSGPACK_ENABLE_SHARED=${MSGPACK_ENABLE_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/msgpack)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/msgpack/COPYING ${CURRENT_PACKAGES_DIR}/share/msgpack/copyright)
