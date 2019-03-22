include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF releases/CGAL-4.13
    SHA512 3a12d7f567487c282928a162a47737c41c22258556ca0083b9cf492fc8f0a7c334b491b14dbfd6a62e71feeeb1b4995769c13a604e0882548f21c41b996d4eaf
    HEAD_REF master
)

set(WITH_CGAL_Qt5  OFF)
if("qt" IN_LIST FEATURES)
  set(WITH_CGAL_Qt5 ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCGAL_HEADER_ONLY=ON
        -DCGAL_INSTALL_CMAKE_DIR=share/cgal
        -DWITH_CGAL_Qt5=${WITH_CGAL_Qt5}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
else()
    foreach(ROOT ${CURRENT_PACKAGES_DIR}/bin)
        file(REMOVE
            ${ROOT}/cgal_create_CMakeLists
            ${ROOT}/cgal_create_cmake_script
            ${ROOT}/cgal_make_macosx_app
        )
    endforeach()
endif()

file(READ ${CURRENT_PACKAGES_DIR}/share/cgal/CGALConfig.cmake _contents)
string(REPLACE "CGAL_IGNORE_PRECONFIGURED_GMP" "1" _contents "${_contents}")
string(REPLACE "CGAL_IGNORE_PRECONFIGURED_MPFR" "1" _contents "${_contents}")

file(WRITE ${CURRENT_PACKAGES_DIR}/share/cgal/CGALConfig.cmake "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/lib/cgal/CGALConfig.cmake "include (\$\{CMAKE_CURRENT_LIST_DIR\}/../../share/cgal/CGALConfig.cmake)")

file(COPY ${SOURCE_PATH}/Installation/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgal)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cgal/LICENSE ${CURRENT_PACKAGES_DIR}/share/cgal/copyright)

file(
    COPY
        ${SOURCE_PATH}/Installation/LICENSE.BSL
        ${SOURCE_PATH}/Installation/LICENSE.FREE_USE
        ${SOURCE_PATH}/Installation/LICENSE.GPL
        ${SOURCE_PATH}/Installation/LICENSE.LGPL
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgal
)
