vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO KarypisLab/METIS
    REF a6e6a2cfa92f93a3ee2971ebc9ddfc3b0b581ab2
    SHA512 c41168788c287ed9baea3c43c1ea8ef7d0bbdaa340a03cbbb5d0ba2d928d8a6dd83e2b77e7d3fabc58ac6d2b59a4be0492940e31460fe5e1807849cb98e80d2e
    PATCHES
        build-fixes.patch
)
file(COPY "${SOURCE_PATH}/include/" DESTINATION "${SOURCE_PATH}/build/xinclude")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/install_config.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/metis.h" "#ifdef _WINDLL" "#if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/metis.h" "__declspec(dllexport)" "__declspec(dllimport)")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
