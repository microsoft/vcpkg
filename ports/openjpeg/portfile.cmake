include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uclouvain/openjpeg
    REF v2.2.0
    SHA512 20651c380bee582ab1950994c424cc00061ad852e9c5438fb32a9809e3f275571a4cc7e92589add0d91debf2394262e58f441c2dd918809fc1c602ed68396a3a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_CODEC:BOOL=OFF
            -DOPENJPEG_INSTALL_PACKAGE_DIR=share/openjpeg
            -DOPENJPEG_INSTALL_INCLUDE_DIR=include
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

file(READ ${CURRENT_PACKAGES_DIR}/include/openjpeg.h OPENJPEG_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(OPJ_STATIC)" "1" OPENJPEG_H "${OPENJPEG_H}")
else()
    string(REPLACE "defined(OPJ_STATIC)" "0" OPENJPEG_H "${OPENJPEG_H}")
endif()
string(REPLACE "defined(DLL_EXPORT)" "0" OPENJPEG_H "${OPENJPEG_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/openjpeg.h "${OPENJPEG_H}")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openjpeg)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openjpeg/LICENSE ${CURRENT_PACKAGES_DIR}/share/openjpeg/copyright)

vcpkg_copy_pdbs()
