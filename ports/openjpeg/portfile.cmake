vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uclouvain/openjpeg
    REF v2.3.1
    SHA512 339fbc899bddf2393d214df71ed5d6070a3a76b933b1e75576c8a0ae9dfcc4adec40bdc544f599e4b8d0bc173e4e9e7352408497b5b3c9356985605830c26c03
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "jpwl"          BUILD_JPWL
    "mj2"           BUILD_MJ2
    "jpip"          BUILD_JPIP
    "jp3d"          BUILD_JP3D
    )

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_CODEC:BOOL=OFF
            -DOPENJPEG_INSTALL_PACKAGE_DIR=share/openjpeg
            -DOPENJPEG_INSTALL_INCLUDE_DIR=include
            ${FEATURE_OPTIONS}
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
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
