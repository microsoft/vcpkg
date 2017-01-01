include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libbson-1.5.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/mongodb/libbson/archive/1.5.1.tar.gz"
    FILENAME "libbson-1.5.1.tar.gz"
    SHA512 b641e23ca041e532fe566167ad0292d12934e0fae2c110f81bf6ca3b71b5d01b651a604a7ce6da0d1b54b98cd95674ef331ef4e23c2dedfc706f371eac4efaec
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_TESTS=OFF
        -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=ON
)

vcpkg_install_cmake()

file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/libbson-1.0
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/bson-1.0.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/bson-1.0.lib)

    file(RENAME
        ${CURRENT_PACKAGES_DIR}/lib/bson-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/lib/bson-1.0.lib)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/lib/bson-static-1.0.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/bson-1.0.lib)

    # drop the __declspec(dllimport) when building static
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/static.patch
    )
else()
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/bson-static-1.0.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/bson-static-1.0.lib)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libbson RENAME copyright)