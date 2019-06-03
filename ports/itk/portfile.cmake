include(vcpkg_common_functions)

string(LENGTH "${CURRENT_BUILDTREES_DIR}" BUILDTREES_PATH_LENGTH)
if(BUILDTREES_PATH_LENGTH GREATER 50 AND CMAKE_HOST_WIN32)
    message(WARNING "ITKs buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\src\\vcpkg' or using the subst command."
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF 906736bd453e95ccf03b318d3d07cb7884285161
    SHA512 8ac62262d46e7acbb0e5b2e964292ec17e1687bb162b8cec666e5b67acbe3449f093a0b1c03737e9951cb88248ed890805ffd57df6eae21220488620da833c57
    HEAD_REF master
    PATCHES fix_conflict_with_openjp2_pc.patch
)

if ("vtk" IN_LIST FEATURES)
    set(ITKVtkGlue ON)
else()
    set(ITKVtkGlue OFF)
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
        -DITK_LEGACY_REMOVE=ON
        -DITK_FUTURE_LEGACY_REMOVE=ON
        -DITK_USE_64BITS_IDS=ON
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

vcpkg_fixup_cmake_targets() # combines release and debug build configurations

file(RENAME ${CURRENT_PACKAGES_DIR}/vcl_compiler_detection.h ${CURRENT_PACKAGES_DIR}/include/ITK-5.0/vcl_compiler_detection.h)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/vcl_compiler_detection.h)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/itk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/itk/LICENSE ${CURRENT_PACKAGES_DIR}/share/itk/copyright)
