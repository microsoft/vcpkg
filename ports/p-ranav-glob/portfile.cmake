if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
	vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/glob
    REF "v${VERSION}"
    SHA512 2213c416d40dcd3a9e03c64a8d24d24d3d3c78847481efe4f10b26cd63b983a03e5ec5ea77dc0a0461a832793927e0bf237b7a47088fe99dafbb83aa482d2fe8
    HEAD_REF master
    PATCHES
        remove_cpm.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH PACKAGE_PROJECT_PATH
    REPO TheLartians/PackageProject.cmake
    REF v1.3
    SHA512 a33ffd902d8e66f3a5a8304fd52fa4af1f74094877141b067c16ed022c8f40306ad7d334e1e1f9c4ca266a80468e107eb4198c78bafd3481a3e81aa178a3b723
    HEAD_REF master
)

configure_file(
    "${PACKAGE_PROJECT_PATH}/CMakeLists.txt" 
    "${SOURCE_PATH}/PackageProject.cmake"
    COPYONLY
)
configure_file(
    "${PACKAGE_PROJECT_PATH}/Config.cmake.in" 
    "${SOURCE_PATH}/Config.cmake.in"
    COPYONLY
)
configure_file(
    "${PACKAGE_PROJECT_PATH}/version.h.in" 
    "${SOURCE_PATH}/version.h.in"
    COPYONLY
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Glob-1.0" PACKAGE_NAME "Glob")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
