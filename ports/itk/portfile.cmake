vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF d3286c9cc04ba16cc8f73de9a98fbcd7c02f3c7b
    SHA512 c358449870d580aeb10e32f8be0ca39e8a76d8dc06fda973788fafb5971333e546611c399190be49d40f5f3c18a1105d9699eef271a560aff25ce168a396926e
    HEAD_REF master
    PATCHES
        hdf5.patch
        double-conversion.patch
        openjpeg.patch
        openjpeg2.patch
        var_libraries.patch
        wrapping.patch
        python_gpu_wrapping.patch
        opencl.patch
        cufftw.patch
        use-the-lrintf-intrinsic.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "vtk"          Module_ITKVtkGlue
    "cuda"         Module_ITKCudaCommon # Requires RTK?
    #"cuda"         CUDA_HAVE_GPU   # Automatically set by FindCUDA?
    "cufftw"       ITK_USE_CUFFTW
    "opencl"       ITK_USE_GPU
    "tbb"          Module_ITKTBB
    "rtk"          Module_RTK
    "tools"        RTK_BUILD_APPLICATIONS
    # There are a lot of more (remote) modules and options in ITK
    # feel free to add those as a feature
)

if("cufftw" IN_LIST FEATURES)
    # Alternativly set CUFFT_LIB and CUFFTW_LIB
    if(WIN32)
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

if("rtk" IN_LIST FEATURES)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
        message(FATAL_ERROR "RTK is not supported on architecture ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    SET(BUILD_RTK ON)
    list(APPEND ADDITIONAL_OPTIONS
         "-DModule_RTK_GIT_TAG=8099212f715231d093f7d6a1114daecf45d871ed" # RTK latest versions (11.05.2020)
         )
    if("cuda" IN_LIST FEATURES)
        list(APPEND ADDITIONAL_OPTIONS "-DRTK_USE_CUDA=ON")
        #RTK + CUDA + PYTHON + dynamic library linkage will fail and needs upstream fixes.
    endif()
endif()
file(REMOVE_RECURSE "${SOURCE_PATH}/Modules/Remote/RTK")

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
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by more than one feature
        "-DSWIG_EXECUTABLE=${SWIG}"
        "-DSWIG_DIR=${SWIG_DIR}"
        )
    # Due to ITKs internal shenanigans with the variables ......
    if(VCPKG_TARGET_IS_WINDOWS)
        list(APPEND ADDITIONAL_OPTIONS  "-DPython3_LIBRARY_RELEASE:PATH=${CURRENT_INSTALLED_DIR}/lib/python38.lib"
                                        "-DPython3_LIBRARY_DEBUG:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/python38_d.lib"
                                        "-DPython3_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include/python3.8")
        list(APPEND OPTIONS_DEBUG "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/python38_d.lib")
        list(APPEND OPTIONS_RELEASE "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/python38.lib")
    elseif(VCPKG_TARGET_IS_LINUX)
        list(APPEND ADDITIONAL_OPTIONS  "-DPython3_LIBRARY_RELEASE:PATH=${CURRENT_INSTALLED_DIR}/lib/libpython38m.a"
                                        "-DPython3_LIBRARY_DEBUG:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/libpython38md.a"
                                        "-DPython3_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include/python3.8m")
        list(APPEND OPTIONS_DEBUG "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/libpython38md.a")
        list(APPEND OPTIONS_RELEASE "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/libpython38m.a")
    elseif(VCPKG_TARGET_IS_OSX)
        #Need Python3 information on OSX within VCPKG
    endif()
    #ITK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages within vcpkg
endif()

set(USE_64BITS_IDS OFF)
if (VCPKG_TARGET_ARCHITECTURE STREQUAL x64 OR VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
    set(USE_64BITS_IDS ON)
endif()

file(REMOVE_RECURSE "${SOURCE_PATH}/CMake/FindOpenCL.cmake")
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_PKGCONFIG_FILES=OFF
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
        -DITK_USE_SYSTEM_HDF5=ON # HDF5 was problematic in the past and still is. ITK still has not figured out how to do it correctly!
        -DITK_USE_SYSTEM_GDCM=ON
        -DITK_USE_SYSTEM_OpenJPEG=ON # Added by VCPKG
        -DITK_USE_SYSTEM_DCMTK=ON
        -DDCMTK_USE_ICU=ON
        -DITK_USE_SYSTEM_ICU=ON
        #-DITK_USE_SYSTEM_VXL=ON
        #-DITK_USE_SYSTEM_CASTXML=ON # needs to be added to vcpkg_find_acquire_program https://data.kitware.com/api/v1/file/hashsum/sha512/b8b6f0aff11fe89ab2fcd1949cc75f2c2378a7bc408827a004396deb5ff5a9976bffe8a597f8db1b74c886ea39eb905e610dce8f5bd7586a4d6c196d7349da8d/download
        -DITK_USE_SYSTEM_MINC=ON
        -DITK_USE_SYSTEM_SWIG=ON
        -DITK_FORBID_DOWNLOADS=OFF # This should be turned on some day, however for now ITK does download specific versions so it shouldn't spontaneously break. Remote Modules would probably break with this!
        -DINSTALL_GTEST=OFF
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

    OPTIONS_DEBUG   ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
)
if(BUILD_RTK) # Remote Modules are only downloaded on configure.
    # TODO: In the future try to download via vcpkg_from_github and move the files. That way patching does not need this workaround
    vcpkg_apply_patches(SOURCE_PATH "${SOURCE_PATH}/Modules/Remote/RTK" QUIET PATCHES rtk/already_defined.patch rtk/unresolved.patch)
endif()
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

if(TOOL_NAMES)
    vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
