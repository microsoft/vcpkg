vcpkg_buildpath_length_warning(37)

vcpkg_download_distfile(PYTHON_GPU_WRAPPING_PATCH
    URLS https://github.com/InsightSoftwareConsortium/ITK/commit/e9b3d24f782a42f5586169e048b8d289f869d78a.diff?full_index=1
    FILENAME InsightSoftwareConsortium-ITK-python-gpu-wrapping.patch
    SHA512 71526320547b0eb5d0c0e0088e92ff60ba06462b82c531c79784d766361805970d9cad550660c7c85b953ec546b32c181aeab5d9f6d4142764d6f765106982a0
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF "v${VERSION}"
    #[[
        When updating the ITK version and SHA512, remember to update the remote module versions below.
        Try `vcpkg install itk[core,cuda,rtk] --only-downloads` for suggestions and verification.
    #]]
    SHA512 225de9963e8eaf93ac32ca4a75c4e7aa887c8e926483c5aca0a4c77ef0e6cc6db4561f96a9ec3b936524ea698702705e8dc2c4a2e6a155733a12c0b3098ae11c
    HEAD_REF master
    PATCHES
        dependencies.diff
        fftw.diff
        openjpeg.patch
        var_libraries.patch
        wrapping.patch
        use-the-lrintf-intrinsic.patch
        dont-build-gtest.patch
        msvc-static-crt.diff
        "${PYTHON_GPU_WRAPPING_PATCH}"
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/CMake/FindOpenCL.cmake"
    "${SOURCE_PATH}/Modules/ThirdParty/GDCM/src"
    "${SOURCE_PATH}/Modules/ThirdParty/OpenJPEG/src/openjpeg"
    "${SOURCE_PATH}/Modules/ThirdParty/VNL/src"
)

set(cuda_common_ref 0c20c4ef10d81910c8b2ac4e8446a1544fce3b60)
set(cuda_common_sha 0eb1a6fe85e695345a49887cdd65103bedab72e01ae85ed03e16a8a296c6cb69a8d889a57b22dde7fcc69df4f604c274b04234c8ece306d08361fac5db029069)
file(STRINGS "${SOURCE_PATH}/Modules/Remote/CudaCommon.remote.cmake" cuda_common_git_tag REGEX "GIT_TAG")
if(NOT cuda_common_git_tag MATCHES "${cuda_common_ref}")
    message(FATAL_ERROR "cuda_common_ref/sha must be updated, new ${cuda_common_git_tag}")
endif()
if("cuda" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH RTK_SOURCE_PATH
        REPO RTKConsortium/ITKCudaCommon
        REF "${cuda_common_ref}"
        SHA512 "${cuda_common_sha}"
        HEAD_REF master
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/Modules/Remote/CudaCommon")
    file(RENAME "${RTK_SOURCE_PATH}" "${SOURCE_PATH}/Modules/Remote/CudaCommon")
    file(COPY_FILE "${SOURCE_PATH}/Modules/Remote/CudaCommon/LICENSE" "${SOURCE_PATH}/CudaCommon LICENSE")
endif()

set(rtk_ref bfdca5b6b666b4f08f2f7d8039af11a15cc3f831)
set(rtk_sha 10a21fb4b82aa820e507e81a6b6a3c1aaee2ea1edf39364dc1c8d54e6b11b91f22d9993c0b56c0e8e20b6d549fcd6104de4e1c5e664f9ff59f5f93935fb5225a)
file(STRINGS "${SOURCE_PATH}/Modules/Remote/RTK.remote.cmake" rtk_git_tag REGEX "GIT_TAG")
if(NOT rtk_git_tag MATCHES "${rtk_ref}")
    message(FATAL_ERROR "rtk_ref/sha must be updated, new ${rtk_git_tag}")
endif()
if("rtk" IN_LIST FEATURES)
    # (old hint, not verified) RTK + CUDA + PYTHON + dynamic library linkage will fail and needs upstream fixes.
    # RTK's ITK module must be built with ITK.
    vcpkg_from_github(
        OUT_SOURCE_PATH RTK_SOURCE_PATH
        REPO RTKConsortium/RTK
        REF "${rtk_ref}"
        SHA512 "${rtk_sha}"
        HEAD_REF master
        PATCHES
            rtk/cmp0153.diff
            rtk/getopt-win32.diff
    )
    file(REMOVE_RECURSE "${SOURCE_PATH}/Modules/Remote/RTK")
    file(RENAME "${RTK_SOURCE_PATH}" "${SOURCE_PATH}/Modules/Remote/RTK")
    file(COPY_FILE "${SOURCE_PATH}/Modules/Remote/RTK/COPYRIGHT.TXT" "${SOURCE_PATH}/RTK COPYRIGHT.TXT")
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
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND ADDITIONAL_OPTIONS
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
endif()

if("fftw" IN_LIST FEATURES)
    # Never set these options to OFF: dual use with feature 'cufftw'
    list(APPEND ADDITIONAL_OPTIONS
        -DITK_USE_FFTWD=ON
        -DITK_USE_FFTWF=ON
    )
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

if("vtk" IN_LIST FEATURES AND EXISTS "${CURRENT_INSTALLED_DIR}/share/vtk/VTKPython-targets.cmake")
    # 'vtk[python]' is built using the installed 'python3'.
    # For 'find_package(vtk)', itk needs to provide the same version of python.
    # Here, it is a purely *transitive* dependency via 'vtk[python]'.
    include("${CURRENT_INSTALLED_DIR}/share/python3/vcpkg-port-config.cmake")
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}" 
    )
endif()

if("python" IN_LIST FEATURES)
    message(STATUS "${PORT} builds a long time (>1h) with python wrappers enabled!")
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    list(APPEND ADDITIONAL_OPTIONS
        -DITK_WRAP_PYTHON=ON
        -DITK_USE_SYSTEM_CASTXML=ON
        "-DCASTXML_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/castxml/bin/castxml${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by more than one feature
    )
    #ITK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages within vcpkg

    vcpkg_find_acquire_program(SWIG) # Swig is only required for wrapping!
    vcpkg_execute_required_process(
        COMMAND "${SWIG}" -version
        OUTPUT_VARIABLE swig_version
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "swig-version-${TARGET_TRIPLET}"
    )
    string(REGEX REPLACE ".*Version ([0-9.]*).*" "\\1" swig_version "${swig_version}")
    set(swig_expected "4.2.0")
    if(swig_version VERSION_GREATER_EQUAL swig_expected)
        vcpkg_execute_required_process(
            COMMAND "${SWIG}" -swiglib
            OUTPUT_VARIABLE swiglib
            OUTPUT_STRIP_TRAILING_WHITESPACE
            WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
            LOGNAME "swiglib-${TARGET_TRIPLET}"
        )
        list(APPEND ADDITIONAL_OPTIONS
            -DITK_USE_SYSTEM_SWIG=ON
            "-DSWIG_EXECUTABLE=${SWIG}"
            "-DSWIG_DIR=${swiglib}"
        )
    else()
        message(WARNING "Found swig ${swig_version}, but TK needs ${swig_expected}. A binary will be downloaded.")
    endif()
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
        -DITK_USE_SYSTEM_VXL=ON
        #-DITK_USE_SYSTEM_CASTXML=ON # needs to be added to vcpkg_find_acquire_program https://data.kitware.com/api/v1/file/hashsum/sha512/b8b6f0aff11fe89ab2fcd1949cc75f2c2378a7bc408827a004396deb5ff5a9976bffe8a597f8db1b74c886ea39eb905e610dce8f5bd7586a4d6c196d7349da8d/download
        -DITK_USE_SYSTEM_MINC=ON
        -DITK_USE_SYSTEM_GOOGLETEST=ON
        -DEXECUTABLE_OUTPUT_PATH=tools/${PORT}

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
        EXECUTABLE_OUTPUT_PATH
        ITK_USE_SYSTEM_FFTW
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

if("rtk" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ITK-5.4/rtkConfiguration.h" "#define RTK_BINARY_DIR \"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Modules/Remote/RTK\"" "")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ITK-5.4/rtkConfiguration.h" "#define RTK_DATA_ROOT \"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/ExternalData/Modules/Remote/RTK/test\"" "")
endif()

vcpkg_list(SET file_list
    "${SOURCE_PATH}/NOTICE"
    "${SOURCE_PATH}/LICENSE"
)
if("cuda" IN_LIST FEATURES)
    vcpkg_list(APPEND file_list
        "${SOURCE_PATH}/CudaCommon LICENSE"
    )
endif()
if("rtk" IN_LIST FEATURES)
    vcpkg_list(APPEND file_list
        "${SOURCE_PATH}/RTK COPYRIGHT.TXT"
    )
endif()
vcpkg_install_copyright(FILE_LIST ${file_list})
