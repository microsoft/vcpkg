include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF 14b74af735aee8bfbe9d6a222835e1c2db1d8d88
    SHA512 b826a4966b8dfe9532b1f1f719bb91afd7bf1baf6fabe7a846aba361564069dcc01c19d601a6bef500680370582169d7b764e9425c72766462493328ee6345d9
    HEAD_REF master
)

if ("vtk" IN_LIST FEATURES)
    set(ITKVtkGlue ON)
else()
    set(ITKVtkGlue OFF)
endif()

# directory path length needs to be shorter than 50 characters
set(ITK_BUILD_DIR ${CURRENT_BUILDTREES_DIR}/ITK)
if(EXISTS ${ITK_BUILD_DIR})
  file(REMOVE_RECURSE ${ITK_BUILD_DIR})
endif()
file(RENAME ${SOURCE_PATH} ${ITK_BUILD_DIR})
set(SOURCE_PATH "${ITK_BUILD_DIR}")

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

        # I havn't tried Python wrapping in vcpkg
        #-DITK_WRAP_PYTHON=ON
        #-DITK_PYTHON_VERSION=3

        -DITK_USE_SYSTEM_HDF5=ON # HDF5 was problematic in the past
        -DModule_ITKVtkGlue=${ITKVtkGlue} # optional feature

        -DModule_IOSTL=ON # example how to turn on a non-default module
        -DModule_MorphologicalContourInterpolation=ON # example how to turn on a remote module
        -DModule_RLEImage=ON # example how to turn on a remote module
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets() # combines release and debug build configurations

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/itk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/itk/LICENSE ${CURRENT_PACKAGES_DIR}/share/itk/copyright)
