vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO argtable/argtable
    REF argtable-2.13
    FILENAME "argtable2-13.tar.gz"
    SHA512 3d8303f3ba529e3241d918c0127a16402ece951efb964d14a06a3a7d29a252812ad3c44e96da28798871e9923e73a2cfe7ebc84139c1397817d632cae25c4585
    PATCHES
        0001-fix-install-dirs.patch
        0002-include-correct-headers.patch
        0003-add-dependence-getopt.patch
)

set(HAVE_GETOPT_H "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
   set(HAVE_GETOPT_H 1)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
        -DHAVE_GETOPT_H=${HAVE_GETOPT_H}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
