include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF 27859944b4d96797030fc018892d5123b7cba0b2
    SHA512 020d4398fcae0607cd3fe1bd22a190fbe1d45cba0c7e3c95d6d3dfb6d23c43949a1608069972e511f5d47fc787c350c0a0a0085faa2f4b9fd26ce101376752c6 
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
