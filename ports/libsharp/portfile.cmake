# Healpix is user and effective maintainer of libsharp.
# Their version 1.0.0 was first distributed with Healpix 3.60.
# cf. https://repology.org/project/libsharp/information
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO healpix
    REF Healpix_3.83
    FILENAME "Healpix_3.83_2024Nov13.tar.gz"
    SHA512 95d8cc4aa6075f7b129d7b117c25ba66deddc25824dbd56d2e3ac8469004452ec2c9736b3a940bd3dcd27a1db4751366068b4ca534b5b853451c43c35244ca52
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}/src/common_libraries/libsharp"
    AUTORECONF
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" COMMENT [[
libsharp is licensed under GNU General Public License version 2 or later.

libsharp includes pocketfft source files which are licensed under a
3-clause BSD style license, Copyright (C) 2004-2019 Max-Planck-Society.
]])
