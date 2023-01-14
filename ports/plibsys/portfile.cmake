vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saprykin/plibsys
    REF 0.0.4
    SHA512 61957666fb454469e1ff68435463eaf426e960caed33540dbb495e1aa7c446c9803d100f33f1a6ea70d5f2ee2d0d19ec315f3a8c651747f65a186ad061c05e51
    HEAD_REF master
    PATCHES
        fix_configuration.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PLIBSYS_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPLIBSYS_TESTS=OFF
        -DPLIBSYS_COVERAGE=OFF
        -DPLIBSYS_BUILD_DOC=OFF
        -DPLIBSYS_BUILD_STATIC=${PLIBSYS_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
