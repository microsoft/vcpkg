vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF releases/CGAL-5.0.2
    SHA512 108f1d6f68674e123fd90143049f30a7e7965827468828f75ba7ae0b7ba174690520bafdf0648853c1b28895d6a9a0c7349c03e678c13395a84ffe7397c97e99
    HEAD_REF master
)

set(WITH_CGAL_Qt5  OFF)
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    qt WITH_CGAL_Qt5
    )


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCGAL_HEADER_ONLY=ON
        -DCGAL_INSTALL_CMAKE_DIR=share/cgal
        ${FEATURE_OPTIONS}
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


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(
    COPY
        ${SOURCE_PATH}/Installation/LICENSE.BSL
        ${SOURCE_PATH}/Installation/LICENSE.FREE_USE
        ${SOURCE_PATH}/Installation/LICENSE.GPL
        ${SOURCE_PATH}/Installation/LICENSE.LGPL
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgal
)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/cgal)
