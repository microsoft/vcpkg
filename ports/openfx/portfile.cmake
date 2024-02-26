if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openfx
    TAG OFX_Release_1_4_TAG
    REF a355991
    SHA512 cda67fd3aa30fb01a580e8c42cd06284f83e5ae06e95c4fda7adb09f4130853aedb3d908b6c465025415973b45b72b17711c646b5b6faeff988b60ad80b0a4c2
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

