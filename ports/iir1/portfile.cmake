vcpkg_fail_port_install(ON_TARGET "uwp" "osx")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/iir1-1.8.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/berndporr/iir1/archive/1.8.0.zip"
    FILENAME "iir1-1.8.0.zip"
    SHA512 e141f4829893ea26f665d32459c2b5d5593e64ed009cd52cb892ef229c8ee6fc718b1718d9cff3856633c23021ebf67a4a9026971e3279438994336b38883754
)
vcpkg_extract_source_archive(${ARCHIVE})

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS
        -DKEYSTONE_BUILD_STATIC=${KEYSTONE_BUILD_STATIC}
        -DKEYSTONE_BUILD_SHARED=${KEYSTONE_BUILD_SHARED}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH  lib/cmake)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
