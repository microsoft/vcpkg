include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpfr-3.1.5)
vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mpfr.org/mpfr-current/mpfr-3.1.5.tar.xz"
    FILENAME "mpfr-3.1.5.tar.xz"
    SHA512 3643469b9099b31e41d6ec9158196cd1c30894030c8864ee5b1b1e91b488bccbf7c263c951b03fe9f4ae6f9d29279e157a7dfed0885467d875f107a3d964f032
)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpfr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mpfr/COPYING ${CURRENT_PACKAGES_DIR}/share/mpfr/copyright)
