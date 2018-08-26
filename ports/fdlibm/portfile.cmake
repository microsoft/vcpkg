include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "https://android.googlesource.com/platform/external/fdlibm/+archive/59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac.tar.gz"
    FILENAME "fdlibm-59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac.tar.gz"
    SHA512 9ce2547ae73d6e92a587654c63fc1b216cf51cf67a4a937a0184bdae794c0d0e21451ae302fe9e11640ee6f15f21fb59d2e21bd754a997a9be3250ce7d061f2e
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libm5.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG 
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fdlibm RENAME copyright)
