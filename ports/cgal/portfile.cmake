include(vcpkg_common_functions)

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CGAL/cgal
    REF 55a05c5a23c1a5721f8cba3a7b5485b9a1f2f663 #4.14.1
    SHA512 ec1a0a87b433b2509287f19d50bde12e097d0b279b2f35d90480d8fc5dc52d0ece6bb83904caeac7a85e1a1da536aea9d2b27a2ee922b84e9528ced78ebbd53e
    HEAD_REF master
)

# Remove CMakeCache.txt to support compiler ninja
file(REMOVE_RECURSE ${OUT_SOURCE_PATH}/Maintenance/infrastructure)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    qt WITH_CGAL_Qt5
    headeronly CGAL_HEADER_ONLY
    demo WITH_demos
    test WITH_tests
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DCGAL_INSTALL_CMAKE_DIR=share/CGAL
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

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
