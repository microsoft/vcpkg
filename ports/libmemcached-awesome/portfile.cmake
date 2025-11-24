vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awesomized/libmemcached
    REF ${VERSION}
    SHA512 0a10a2431142ec6e4547f82fdd35b55c018264e5f8c39910a65252c3f53d862fb5945e7a671951915aac076767cc995740b3e499eb584017a38eb2d1e82171fb
    HEAD_REF v1.x
    PATCHES
        in_port_t.diff
        no-static-exports.diff
        p9y-targets.diff
)

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

# Options are initialized from env variables. Control env.
foreach(var IN ITEMS
    BUILD_TESTING
    BUILD_DOCSONLY BUILD_DOCS BUILD_DOCS_HTML BUILD_DOCS_MAN BUILD_DOCS_MANGZ
    ENABLE_SASL
    ENABLE_DTRACE
    ENABLE_HASH_HSIEH
    ENABLE_OPENSSL_CRYPTO
    # Extra deps: pthreads, libevent
    ENABLE_MEMASLAP
)
    set(ENV{${var}} OFF)
endforeach()
set(ENV{ENABLE_SANITIZERS} "")
set(ENV{ENABLE_HASH_FNV64} ON)
set(ENV{ENABLE_HASH_MURMUR} ON)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DVCPKG_LOCK_FIND_PACKAGE_Backtrace=OFF"
        "-DVCPKG_LOCK_FIND_PACKAGE_PkgConfig=OFF"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libmemcached-awesome")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES memcapable memcat memcp memdump memerror memexist memflush memparse memping memrm memslap memstat memtouch)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libmemcached-1.0/visibility.h" "#if defined(LIBMEMCACHED_STATIC)" "#if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libhashkit-1.0/visibility.h" "#if defined(HASHKIT_STATIC)" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
