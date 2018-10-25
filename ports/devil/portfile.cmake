include(vcpkg_common_functions)

set(DEVIL_VERSION 1.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DentonW/DevIL
    REF v${DEVIL_VERSION}
    SHA512 4aed5e50a730ece8b1eb6b2f6204374c6fb6f5334cf7c880d84c0f79645ea7c6b5118f57a7868a487510fc59c452f51472b272215d4c852f265f58b5857e17c7
    HEAD_REF master
    PATCHES
        0001_fix-encoding.patch
        0002_fix-missing-mfc-includes.patch
        enable-static.patch
)

set(IL_NO_PNG 1)
if("libpng" IN_LIST FEATURES)
    set(IL_NO_PNG 0)
endif()

set(IL_NO_TIF 1)
if("libtiff" IN_LIST FEATURES)
    set(IL_NO_TIF 0)
endif()

set(IL_NO_JPG 1)
if("libjpeg" IN_LIST FEATURES)
    set(IL_NO_JPG 0)
endif()

set(IL_NO_EXR 1)
if("openexr" IN_LIST FEATURES)
    set(IL_NO_EXR 0)
endif()

set(IL_NO_JP2 1)
if("jasper" IN_LIST FEATURES)
    set(IL_NO_JP2 0)
endif()

set(IL_NO_MNG 1)
#if("libmng" IN_LIST FEATURES)
#    set(IL_NO_MNG 0)
#endif()

set(IL_NO_LCMS 1)
if("lcms" IN_LIST FEATURES)
    set(IL_NO_LCMS 0)
endif()

set(IL_USE_DXTC_NVIDIA 0)
#if("nvtt" IN_LIST FEATURES)
#    set(IL_USE_DXTC_NVIDIA 1)
#endif()

set(IL_USE_DXTC_SQUISH 0)
#if("libsquish" IN_LIST FEATURES)
#    set(IL_USE_DXTC_SQUISH 1)
#endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/DevIL
    PREFER_NINJA
    OPTIONS
        -DIL_NO_PNG=${IL_NO_PNG}
        -DIL_NO_TIF=${IL_NO_TIF}
        -DIL_NO_JPG=${IL_NO_JPG}
        -DIL_NO_EXR=${IL_NO_EXR}
        -DIL_NO_JP2=${IL_NO_JP2}
        -DIL_NO_MNG=${IL_NO_MNG}
        -DIL_NO_LCMS=${IL_NO_LCMS}
        -DIL_USE_DXTC_NVIDIA=${IL_USE_DXTC_NVIDIA}
        -DIL_USE_DXTC_SQUISH=${IL_USE_DXTC_SQUISH}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/devil RENAME copyright)
