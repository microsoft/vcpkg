vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://git.code.sf.net/p/qwt/git"
    REF "907846e0e981b216349156ee83b13208faae2934"
    FETCH_REF qwt-6.2
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" QWT_BUILD_DLL)
else()
    set(QWT_BUILD_DLL OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DLL=${QWT_BUILD_DLL}
        -DWITH_PLOT=ON
        -DWITH_OPENGL=ON
        -DWITH_SVG=ON
        -DWITH_POLAR=ON
        -DWITH_WIDGETS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
