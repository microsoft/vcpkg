include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 37 AND CMAKE_HOST_WIN32)
    message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF releases/CGAL-4.14
    SHA512 c70b3ad475f6b2c03ecb540e195b4d26a709205c511b0c705dfddb5b14ef372453ce1d4d49ed342fcd21ba654dea793e91c058afae626276bfb3cfd72bccb382
    HEAD_REF master
    PATCHES
        cgal_target_fix.patch
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

vcpkg_test_cmake(PACKAGE_NAME CGAL)
