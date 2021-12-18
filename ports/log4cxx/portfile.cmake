set(VERSION 0.12.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/logging/log4cxx/${VERSION}/apache-log4cxx-${VERSION}.tar.gz"
    FILENAME "apache-log4cxx-${VERSION}.tar.gz"
    SHA512 00fe571f9c511bf93b17cac8269ce00f7e817e8d723acf62bddff1bbe0e7facd0ab2fd75c01a93870f7e5c66718b2b73fc22c5f193bfd204e34d052b1123e60d  
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        expat.patch
        linux.patch
        pkgconfig.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLOG4CXX_INSTALL_PDB=OFF # Installing pdbs failed on debug static. So, disable it and let vcpkg_copy_pdbs() do it
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/log4cxx)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_fixup_pkgconfig()
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/${PORT}/log4cxxConfig.cmake" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/log4cxxConfig.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(expat CONFIG)
${_contents}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
