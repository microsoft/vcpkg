include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF releases/CGAL-4.11.1
    SHA512 fa5bdf62020bfba9d0774dd6333d0a4c6800d4d4c65a8be640710dde5446eca47941567ef801ace5b30b6027f5442b42bb7e0175f52758c5acc595b72cc031f6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCGAL_INSTALL_CMAKE_DIR=share/cgal
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(READ ${CURRENT_PACKAGES_DIR}/share/cgal/CGALConfig.cmake _contents)
string(REPLACE "CGAL_IGNORE_PRECONFIGURED_GMP" "1" _contents "${_contents}")
string(REPLACE "CGAL_IGNORE_PRECONFIGURED_MPFR" "1" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/cgal/CGALConfig.cmake "${_contents}")

# Handle copyright of suitesparse and metis
file(COPY ${SOURCE_PATH}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgal)
