include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF f7c3c8212b56c0d6dae63787efc99093f4383415
    SHA512 fc40483b5f0e2071c3458cbd67ee7e503f68b7f6a1bbb525b6003d1a440e662cb85c257167ce6d55a73e0cc49b27a7d2b56dcf6b5eeddc78772567fdc48ba160
    HEAD_REF master
)

set(WITH_CGAL_Qt5  OFF)
if("qt5" IN_LIST FEATURES)
  set(WITH_CGAL_Qt5 ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCGAL_INSTALL_CMAKE_DIR=share/cgal
        -DWITH_CGAL_Qt5=${WITH_CGAL_Qt5}
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
