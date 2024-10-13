vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF "v${VERSION}"
    SHA512 3a98ececf258aac545f094dd3e97918c93cc82bc623ddf793c4bf0162ab06c83fbfd4d08130bdec6e617bda85dd17225488bc1394bc91b17f1232126a5d990db
    #[[
        When updating the ITK version and SHA512, remember to update the remote module versions below.
    #]]
    HEAD_REF master
    PATCHES
        double-conversion.patch
        openjpeg.patch
        openjpeg2.patch
        var_libraries.patch
        wrapping.patch
        opencl.patch
        use-the-lrintf-intrinsic.patch
        dont-build-gtest.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/CMake/FindOpenCL.cmake")

if("rtk" IN_LIST FEATURES)
    # (old hint, not verified) RTK + CUDA + PYTHON + dynamic library linkage will fail and needs upstream fixes.
    # RTK's ITK module must be built with ITK.
    vcpkg_from_github(
        OUT_SOURCE_PATH RTK_SOURCE_PATH
        REPO RTKConsortium/RTK
        # Cf. Modules/Remote/RTK.remote.cmake
        REF bfdca5b6b666b4f08f2f7d8039af11a15cc3f831
        SHA512 10a21fb4b82aa820e507e81a6b6a3c1aaee2ea1edf39364dc1c8d54e6b11b91f22d9993c0b56c0e8e20b6d549fcd6104de4e1c5e664f9ff59f5f93935fb5225a
        HEAD_REF master
        PATCHES
            rtk/cmp0153.diff
            rtk/getopt-win32.diff
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/Modules/Remote/RTK")
    file(RENAME "${RTK_SOURCE_PATH}" "${SOURCE_PATH}/Modules/Remote/RTK")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "vtk"          Module_ITKVtkGlue
        "cuda"         Module_CudaCommon # Requires RTK?
        "cuda"         RTK_USE_CUDA
        #"cuda"         CUDA_HAVE_GPU   # Automatically set by FindCUDA?
        "cufftw"       ITK_USE_CUFFTW
        "opencl"       ITK_USE_GPU
        "tbb"          Module_ITKTBB
        "rtk"          Module_RTK
        "tools"        RTK_BUILD_APPLICATIONS
        "opencv"       Module_ITKVideoBridgeOpenCV
        # There are a lot of more (remote) modules and options in ITK
        # feel free to add those as a feature
)

if("cufftw" IN_LIST FEATURES)
    # Alternativly set CUFFT_LIB and CUFFTW_LIB
    if(VCPKG_TARGET_IS_WINDOWS)
        file(TO_CMAKE_PATH "$ENV{CUDA_PATH}" CUDA_PATH)
        set(CUDA_LIB_PATH "${CUDA_PATH}")

        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
            string(APPEND CUDA_LIB_PATH "/lib/x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            string(APPEND CUDA_LIB_PATH "/lib/Win32")
            message(FATAL_ERROR "CUFFTW is not supported on architecture ${VCPKG_TARGET_ARCHITECTURE}")
        else()
            message(FATAL_ERROR "Architecture ${VCPKG_TARGET_ARCHITECTURE} not supported !")
        endif()

        list(APPEND ADDITIONAL_OPTIONS
             "-DFFTW_LIB_SEARCHPATH=${CUDA_LIB_PATH}"
             "-DFFTW_INCLUDE_PATH=${CUDA_PATH}/include"
             "-DCUFFTW_INCLUDE_PATH=${CUDA_PATH}/include"
             )
    endif()
endif()

if("opencl" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS # Wrapping options required by OpenCL if build with Python Wrappers
         -DITK_WRAP_unsigned_long_long=ON
         -DITK_WRAP_signed_long_long=ON
         )
endif()
if("tools" IN_LIST FEATURES)

    if("rtk" IN_LIST FEATURES)
        list(APPEND TOOL_NAMES rtkadmmtotalvariation rtkadmmwavelets rtkamsterdamshroud rtkbackprojections rtkbioscangeometry rtkcheckimagequality rtkconjugategradient
                               rtkdigisensgeometry rtkdrawgeometricphantom rtkdrawshepploganphantom rtkdualenergysimplexdecomposition rtkelektasynergygeometry rtkextractphasesignal
                               rtkextractshroudsignal rtkfdk rtkfdktwodweights rtkfieldofview rtkforwardprojections rtkfourdconjugategradient rtkfourdfdk rtkfourdrooster rtkfourdsart
                               rtkgaincorrection rtki0estimation rtkimagxgeometry rtkiterativefdk rtklagcorrection rtklastdimensionl0gradientdenoising rtklut rtkmaskcollimation rtkmcrooster
                               rtkmotioncompensatedfourdconjugategradient rtkorageometry rtkosem rtkoverlayphaseandshroud rtkparkershortscanweighting rtkprojectgeometricphantom
                               rtkprojectionmatrix rtkprojections rtkprojectshepploganphantom rtkramp rtkrayboxintersection rtkrayquadricintersection rtkregularizedconjugategradient
                               rtksart rtkscatterglarecorrection rtksimulatedgeometry rtkspectraldenoiseprojections rtkspectralforwardmodel rtkspectralonestep rtkspectralrooster rtkspectralsimplexdecomposition
                               rtksubselect rtktotalnuclearvariationdenoising rtktotalvariationdenoising rtktutorialapplication rtkvarianobigeometry rtkvarianprobeamgeometry rtkvectorconjugategradient
                               rtkwangdisplaceddetectorweighting rtkwarpedbackprojectsequence rtkwarpedforwardprojectsequence rtkwaveletsdenoising rtkxradgeometry)
    endif()
endif()
if("vtk" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
         "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by mvtk if vtk[python] was build
         )
endif()
if("python" IN_LIST FEATURES)
    message(STATUS "${PORT} builds a long time (>1h) with python wrappers enabled!")
    vcpkg_find_acquire_program(PYTHON3)
    vcpkg_find_acquire_program(SWIG) # Swig is only required for wrapping!
    get_filename_component(SWIG_DIR "${SWIG}" DIRECTORY)
    list(APPEND ADDITIONAL_OPTIONS
        -DITK_WRAP_PYTHON=ON
        -DITK_USE_SYSTEM_CASTXML=ON
        "-DCASTXML_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/castxml/bin/castxml${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by more than one feature
        "-DSWIG_EXECUTABLE=${SWIG}"
        "-DSWIG_DIR=${SWIG_DIR}"
        )
    #ITK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages within vcpkg
endif()
if("opencv" IN_LIST FEATURES)
    message(STATUS "${PORT} includes the ITKVideoBridgeOpenCV")
    list(APPEND ADDITIONAL_OPTIONS
        -DModule_ITKVideoBridgeOpenCV:BOOL=ON
        )
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "static")
    list(APPEND ADDITIONAL_OPTIONS
        -DITK_MSVC_STATIC_RUNTIME_LIBRARY=ON
        -DITK_MSVC_STATIC_CRT=ON
    )
endif()

set(USE_64BITS_IDS OFF)
if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
    set(USE_64BITS_IDS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Perl=ON
        -DITK_DOXYGEN_HTML=OFF
        -DITK_FORBID_DOWNLOADS=ON
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
        -DITK_USE_SYSTEM_HDF5=ON # HDF5 was problematic in the past and still is. ITK still has not figured out how to do it correctly!
        -DITK_USE_SYSTEM_GDCM=ON
        -DITK_USE_SYSTEM_OpenJPEG=ON # Added by VCPKG
        #-DITK_USE_SYSTEM_VXL=ON
        #-DITK_USE_SYSTEM_CASTXML=ON # needs to be added to vcpkg_find_acquire_program https://data.kitware.com/api/v1/file/hashsum/sha512/b8b6f0aff11fe89ab2fcd1949cc75f2c2378a7bc408827a004396deb5ff5a9976bffe8a597f8db1b74c886ea39eb905e610dce8f5bd7586a4d6c196d7349da8d/download
        -DITK_USE_SYSTEM_MINC=ON
        -DITK_USE_SYSTEM_GOOGLETEST=ON
        -DEXECUTABLE_OUTPUT_PATH=tools/${PORT}

        # TODO
        #-DVXL_USE_GEOTIFF=ON
        -DVXL_USE_LFS=ON

        -DITK_MINIMUM_COMPLIANCE_LEVEL:STRING=1 # To Display all remote modules within cmake-gui
        #-DModule_IOSTL=ON # example how to turn on a non-default module
        #-DModule_MorphologicalContourInterpolation=ON # example how to turn on a remote module
        #-DModule_RLEImage=ON # example how to turn on a remote module

        # Some additional wraping options
        #-DITK_WRAP_double=ON
        #-DITK_WRAP_complex_double=ON
        #-DITK_WRAP_covariant_vector_double=ON
        #-DITK_WRAP_vector_double=ON

        ${FEATURE_OPTIONS}
        ${ADDITIONAL_OPTIONS}

    OPTIONS_DEBUG
        -DRTK_BUILD_APPLICATIONS=OFF

    MAYBE_UNUSED_VARIABLES
        ITK_USE_SYSTEM_GOOGLETEST
        RTK_BUILD_APPLICATIONS
        RTK_USE_CUDA
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/ITK-5.4/vcl_where_root_dir.h")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ITK-5.4/itk_eigen.h" "include(${SOURCE_PATH}/CMake/UseITK.cmake)" "include(UseITK)")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ITK-5.4/itk_eigen.h" "message(STATUS \"From ITK: Eigen3_DIR: ${CURRENT_INSTALLED_DIR}/share/eigen3\")" "")

if("rtk" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ITK-5.4/rtkConfiguration.h" "#define RTK_BINARY_DIR \"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Modules/Remote/RTK\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ITK-5.4/rtkConfiguration.h" "#define RTK_DATA_ROOT \"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/ExternalData/Modules/Remote/RTK/test\"" "")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
