if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mad/libmad
    REF 0.15.1b
    FILENAME "libmad-0.15.1b.tar.gz"
    SHA512 2cad30347fb310dc605c46bacd9da117f447a5cabedd8fefdb24ab5de641429e5ec5ce8af7aefa6a75a3f545d3adfa255e3fa0a2d50971f76bc0c4fc0400cc45
    PATCHES 0001-Fix-MSVC-ARM.patch
)

#The archive only contains a Visual Studio 6.0 era DSP project file, so use a custom CMakeLists.txt
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/mad.pc.in" DESTINATION "${SOURCE_PATH}")

#Use the msvc++ config.h header
file(COPY "${SOURCE_PATH}/msvc++/config.h" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DVERSION=${VERSION}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
