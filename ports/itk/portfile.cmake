include(vcpkg_common_functions)

vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF v5.0.1
    SHA512 242ce66cf83f82d26f20d2099108295e28c8875e7679126ba023834bf0e94454460ba86452a94c8ddaea93d2314befc399f2b151d7294370d4b47f0e9798e77f
    HEAD_REF master
    PATCHES
        fix_openjpeg_search.patch
        fix_libminc_config_path.patch
)

if ("vtk" IN_LIST FEATURES)
    set(ITKVtkGlue ON)
else()
    set(ITKVtkGlue OFF)
endif()

set(USE_64BITS_IDS OFF)
if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
    set(USE_64BITS_IDS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DDO_NOT_INSTALL_ITK_TEST_DRIVER=ON
        -DITK_INSTALL_DATA_DIR=share/itk/data
        -DITK_INSTALL_DOC_DIR=share/itk/doc
        -DITK_INSTALL_PACKAGE_DIR=share/itk
        -DITK_USE_64BITS_IDS=${USE_64BITS_IDS}
        -DITK_USE_CONCEPT_CHECKING=ON
        #-DITK_USE_SYSTEM_LIBRARIES=ON # enables USE_SYSTEM for all third party libraries, some of which do not have vcpkg ports such as CastXML, SWIG, MINC etc
        -DITK_USE_SYSTEM_DOUBLECONVERSION=ON
        -DITK_USE_SYSTEM_EXPAT=ON
        -DITK_USE_SYSTEM_JPEG=ON
        -DITK_USE_SYSTEM_PNG=ON
        -DITK_USE_SYSTEM_TIFF=ON
        -DITK_USE_SYSTEM_ZLIB=ON
        -DITK_USE_SYSTEM_EIGEN=ON
        # This should be turned on some day, however for now ITK does download specific versions so it shouldn't spontaneously break
        -DITK_FORBID_DOWNLOADS=OFF

        -DITK_SKIP_PATH_LENGTH_CHECKS=ON

        # I haven't tried Python wrapping in vcpkg
        #-DITK_WRAP_PYTHON=ON
        #-DITK_PYTHON_VERSION=3

        -DITK_USE_SYSTEM_HDF5=ON # HDF5 was problematic in the past
        -DModule_ITKVtkGlue=${ITKVtkGlue} # optional feature

        -DModule_IOSTL=ON # example how to turn on a non-default module
        -DModule_MorphologicalContourInterpolation=ON # example how to turn on a remote module
        -DModule_RLEImage=ON # example how to turn on a remote module
        -DGDCM_USE_SYSTEM_OPENJPEG=ON #Use port openjpeg instead of own third-party
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
