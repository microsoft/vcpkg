vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF d3286c9cc04ba16cc8f73de9a98fbcd7c02f3c7b
    SHA512 c358449870d580aeb10e32f8be0ca39e8a76d8dc06fda973788fafb5971333e546611c399190be49d40f5f3c18a1105d9699eef271a560aff25ce168a396926e
    HEAD_REF master
    PATCHES
        #fix_openjpeg_search.patch
        #fix_libminc_config_path.patch
        wip.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "vtk"          Module_ITKVtkGlue
    "cufftw"       ITK_USE_CUFFTW
    "opencl"       ITK_USE_GPU
)
if("vtk" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
         "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by mvtk if vtk[python] was build
         )
endif()
if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DITK_WRAP_PYTHON=ON
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_LIBRARY_RELEASE:PATH=${CURRENT_INSTALLED_DIR}/lib/python37.lib"
        "-DPython3_LIBRARY_DEBUG:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib"
        "-DPython3_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include/python3.7"
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by more than one feature
        )
        #"-DPython3_FIND_ABI=ANY\\\\\\\\\\\\\\\\\\\\\\\\;ANY\\\\\\\\\\\\\\\\\\\\\\\\;ANY"
        #"-DPython3_VERSION=3.7"
        #-DPython3_LIBRARIES="debug\\\\\\\\\\\\\\\\\\\\\\\\;${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib\\\\\\\\\\\\\\\\\\\\\\\\;optimized\\\\\\\\\\\\\\\\\\\\\\\\;${CURRENT_INSTALLED_DIR}/lib/python37.lib"

    list(APPEND OPTIONS_DEBUG "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib")
    list(APPEND OPTIONS_RELEASE "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/python37.lib")
    #ITK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages
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
        -DITK_DOXYGEN_HTML=OFF
        -DDO_NOT_INSTALL_ITK_TEST_DRIVER=ON
        -DITK_SKIP_PATH_LENGTH_CHECKS=ON
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
        -DITK_USE_SYSTEM_FFTW=ON
        -DITK_USE_SYSTEM_HDF5=ON # HDF5 was problematic in the past
        # This should be turned on some day, however for now ITK does download specific versions so it shouldn't spontaneously break
        -DITK_FORBID_DOWNLOADS=OFF

        -DINSTALL_GTEST=OFF
        -DITK_USE_SYSTEM_GOOGLETEST=ON
        -DEXECUTABLE_OUTPUT_PATH=tools/${PORT}
        
        # TODO
        #-DVXL_USE_GEOTIFF=ON
        -DVXL_USE_LFS=ON
        
        #-DModule_IOSTL=ON # example how to turn on a non-default module
        #-DModule_MorphologicalContourInterpolation=ON # example how to turn on a remote module
        #-DModule_RLEImage=ON # example how to turn on a remote module
        #-DGDCM_USE_SYSTEM_OPENJPEG=ON #Use port openjpeg instead of own third-party
        -DITK_WRAP_double=ON
        -DITK_WRAP_complex_double=ON
        -DITK_WRAP_covariant_vector_double=ON
        -DITK_WRAP_vector_double=ON
        ${FEATURE_OPTIONS}
        ${ADDITIONAL_OPTIONS}
        
    OPTIONS_DEBUG   ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

set(_files itkLIBMINCConfig UseitkLIBMINC)
foreach(_file IN LISTS _files)
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/cmake/${_file}.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${_file}.cmake")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Without VTK

# -- The following OPTIONAL packages have been found:

 # * Git
 # * Threads
 # * HDF5
 # * LibLZMA
 # * Python3
 # * Perl

# -- The following REQUIRED packages have been found:

 # * double-conversion
 # * EXPAT
 # * SZIP
 # * TIFF
 # * JPEG
 # * ZLIB
 # * PNG
 # * Eigen3 (required version >= 3.3)
 # * ITK

# -- The following OPTIONAL packages have not been found:

 # * KWStyle (required version >= 1.0.1)
 # * cppcheck
 # * PkgConfig

# -- Configuring done
# -- Generating done
# -- Build files have been written to: D:/qt2/buildtrees/itk/x64-windows-dbg