include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pqp-1.3/PQP_v1.3)
vcpkg_download_distfile(ARCHIVE
    URLS "http://gamma.cs.unc.edu/software/downloads/SSV/pqp-1.3.tar.gz"
    FILENAME "pqp-1.3.tar.gz"
    SHA512 baad7b050b13a6d13de5110cdec443048a3543b65b0d3b30d1b5f737b46715052661f762ef71345d39978c0c788a30a3a935717664806b4729722ee3594ebdc1
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-math-functions.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSOURCE=${SOURCE_PATH}
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pqp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pqp/LICENSE ${CURRENT_PACKAGES_DIR}/share/pqp/copyright)
