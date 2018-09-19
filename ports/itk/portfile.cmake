include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF d92873e33e8a54e933e445b92151191f02feab42
    SHA512 0e3ebd27571543e1c497377dd9576a9bb0711129be12131109fe9b3c8413655ad14ce4d9ac6e281bac83c57e6032b614bc9ff53ed357d831544ca52f41513b62
    HEAD_REF master
)

# directory path length needs to be shorter than 50 characters
file(RENAME ${SOURCE_PATH} ${CURRENT_BUILDTREES_DIR}/ITK)
set(SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/ITK")

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
        -DITK_FORBID_DOWNLOADS=OFF

        # I havn't tried Python wrapping in vcpkg
        #-DITK_WRAP_PYTHON=ON
        #-DITK_PYTHON_VERSION=3

        # HDF5 must NOT be installed, otherwise it causes: ...\installed\x64-windows-static\include\H5Tpkg.h(25): fatal error C1189: #error:  "Do not include this file outside the H5T package!"
        -DITK_USE_SYSTEM_HDF5=OFF # if ON, causes: ...\buildtrees\itk\x64-windows-static-rel\Modules\ThirdParty\HDF5\src\itk_H5Cpp.h(25): fatal error C1083: Cannot open include file: 'H5Cpp.h': No such file or directory

        # -DModule_ITKVtkGlue=ON # this option requires VTK to be a dependency in CONTROL file. VTK depends on HDF5!
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
