vcpkg_buildpath_length_warning(37)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO InsightSoftwareConsortium/ITK
    REF d3286c9cc04ba16cc8f73de9a98fbcd7c02f3c7b
    SHA512 c358449870d580aeb10e32f8be0ca39e8a76d8dc06fda973788fafb5971333e546611c399190be49d40f5f3c18a1105d9699eef271a560aff25ce168a396926e
    HEAD_REF master
    PATCHES
        #wip.patch
        hdf5.patch
        double-conversion.patch 
        jpeg.patch
        var_libraries.patch
        wrapping.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    "vtk"          Module_ITKVtkGlue
    "cufftw"       ITK_USE_CUFFTW
    "opencl"       ITK_USE_GPU
    "tbb"          Module_ITKTBB
    "rtk"          Module_RTK
    "rtkcuda"      Module_ITKCudaCommon     
    "rtkcuda"      RTK_USE_CUDA               
    "rtkcuda"      CUDA_HAVE_GPU 
    "rtktools"     RTK_BUILD_APPLICATIONS
)

if("cufftw" IN_LIST FEATURES)
    message(STATUS "Warning: feature cufftw does currently not compile and requires and upstream fix!")
    # Alternativly set CUFFT_LIB and CUFFTW_LIB
    if(WIN32)
        file(TO_CMAKE_PATH "$ENV{CUDA_PATH}" CUDA_PATH)
        set(CUDA_LIB_PATH "${CUDA_PATH}")

        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
            string(APPEND CUDA_LIB_PATH "/lib/x64")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            string(APPEND CUDA_LIB_PATH "/lib/Win32")
        else()
            message(FATAL_ERROR "Architecture ${VCPKG_TARGET_ARCHITECTURE} not supported !")
        endif()
        
        list(APPEND ADDITIONAL_OPTIONS
             "-DFFTW_LIB_SEARCHPATH=${CUDA_LIB_PATH}"
             "-DFFTW_INCLUDE_PATH=${CUDA_PATH}/include"
             )
    endif()
endif()
if("rtk" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
         "-DModule_RTK_GIT_TAG=6c5d5c2a25a2dd15d3b5ae1d2b9e6f8360b2208d" # RTK latest versions (08.05.2020)
         )
endif()
if("rtktools" IN_LIST FEATURES)
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
    vcpkg_add_to_path(${SWIG_DIR})
    list(APPEND ADDITIONAL_OPTIONS
        -DITK_WRAP_PYTHON=ON
        -DPython3_FIND_REGISTRY=NEVER
        "-DPython3_LIBRARY_RELEASE:PATH=${CURRENT_INSTALLED_DIR}/lib/python37.lib"
        "-DPython3_LIBRARY_DEBUG:PATH=${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib"
        "-DPython3_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include/python3.7"
        "-DPython3_EXECUTABLE:PATH=${PYTHON3}" # Required by more than one feature
        "-DSWIG_EXECUTABLE=${SWIG}"
        "-DSWIG_DIR=${SWIG_DIR}"
        )

    # Due to ITKs internal shenanigans with the variables ......
    list(APPEND OPTIONS_DEBUG "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/debug/lib/python37_d.lib")
    list(APPEND OPTIONS_RELEASE "-DPython3_LIBRARY=${CURRENT_INSTALLED_DIR}/lib/python37.lib")
    #ITK_PYTHON_SITE_PACKAGES_SUFFIX should be set to the install dir of the site-packages within vcpkg 
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
        #-DITK_USE_SYSTEM_MINC=ON # port needs to be added to VCPKG
        -DITK_USE_SYSTEM_SWIG=ON
        -DITK_FORBID_DOWNLOADS=OFF # This should be turned on some day, however for now ITK does download specific versions so it shouldn't spontaneously break. Remote Modules would probably break with this!
        -DINSTALL_GTEST=OFF
        -DITK_USE_SYSTEM_GOOGLETEST=ON
        -DEXECUTABLE_OUTPUT_PATH=tools/${PORT}
        
        # TODO
        #-DVXL_USE_GEOTIFF=ON
        -DVXL_USE_LFS=ON
        
        #-DModule_IOSTL=ON # example how to turn on a non-default module
        #-DModule_MorphologicalContourInterpolation=ON # example how to turn on a remote module
        #-DModule_RLEImage=ON # example how to turn on a remote module

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

if(TOOL_NAMES)
    vcpkg_coyp_tools(TOOL_NAMES ${TOOL_NAMES})
endif()

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

  # D:\qt2\buildtrees\itk\src\d7c02f3c7b-959337cec2\Modules\ThirdParty\GDCM\src\CMakeLists.txt (13 hits)
	# Line 29: set(GDCM_USE_SYSTEM_EXPAT ON CACHE INTERNAL "")
	# Line 33: set(GDCM_USE_SYSTEM_OPENJPEG OFF CACHE INTERNAL "")
	# Line 36: set(GDCM_USE_SYSTEM_ZLIB ON CACHE INTERNAL "")
	# Line 47: set(GDCM_USE_SYSTEM_LJPEG OFF CACHE INTERNAL "Use system ljpeg (ijg lib)")
	# Line 48: set(GDCM_USE_SYSTEM_OPENSSL OFF CACHE INTERNAL "Use system OpenSSL")
	# Line 49: set(GDCM_USE_SYSTEM_PODOFO OFF CACHE INTERNAL "Use system podofo (pdf)")
	# Line 50: set(GDCM_USE_SYSTEM_POPPLER OFF CACHE INTERNAL "Use system poppler (pdf)")
	# Line 51: set(GDCM_USE_SYSTEM_UUID OFF CACHE INTERNAL "Use system uuid")
	# Line 54: set(GDCM_USE_SYSTEM_CHARLS OFF CACHE INTERNAL "")
	# Line 55: set(GDCM_USE_SYSTEM_JSON OFF CACHE INTERNAL "")
	# Line 56: set(GDCM_USE_SYSTEM_LIBXML2 OFF CACHE INTERNAL "")
	# Line 57: set(GDCM_USE_SYSTEM_PAPYRUS3 OFF CACHE INTERNAL "")
	# Line 58: set(GDCM_USE_SYSTEM_SOCKETXX OFF CACHE INTERNAL "")
    
    # D:\qt2\buildtrees\itk\src\d7c02f3c7b-959337cec2\Modules\ThirdParty\GDCM\src\gdcm\CMakeLists.txt (41 hits)
	# Line 313: option(GDCM_USE_SYSTEM_ZLIB "Use system zlib" OFF)
	# Line 314: option(GDCM_USE_SYSTEM_OPENSSL  "Use system OpenSSL" OFF)
	# Line 318:   option(GDCM_USE_SYSTEM_UUID "Use system uuid" OFF)
	# Line 320: option(GDCM_USE_SYSTEM_EXPAT "Use system expat" OFF)
	# Line 321: option(GDCM_USE_SYSTEM_JSON "Use system json" OFF)
	# Line 322: option(GDCM_USE_SYSTEM_PAPYRUS3 "Use system papyrus3" OFF)
	# Line 323: option(GDCM_USE_SYSTEM_SOCKETXX "Use system socket++" OFF)
	# Line 324: option(GDCM_USE_SYSTEM_LJPEG "Use system ljpeg (ijg lib)" OFF)
	# Line 325: option(GDCM_USE_SYSTEM_OPENJPEG "Use system openjpeg" OFF)
	# Line 326: option(GDCM_USE_SYSTEM_CHARLS "Use system CharLS" OFF)
	# Line 328:   GDCM_USE_SYSTEM_ZLIB
	# Line 329:   GDCM_USE_SYSTEM_OPENSSL
	# Line 330:   GDCM_USE_SYSTEM_UUID
	# Line 331:   GDCM_USE_SYSTEM_EXPAT
	# Line 332:   GDCM_USE_SYSTEM_JSON
	# Line 333:   GDCM_USE_SYSTEM_PAPYRUS3
	# Line 334:   GDCM_USE_SYSTEM_SOCKETXX
	# Line 335:   GDCM_USE_SYSTEM_LJPEG
	# Line 336:   GDCM_USE_SYSTEM_OPENJPEG
	# Line 337:   GDCM_USE_SYSTEM_CHARLS
	# Line 339: option(GDCM_USE_SYSTEM_POPPLER "Use system poppler (pdf)" OFF)
	# Line 340: if(GDCM_USE_SYSTEM_POPPLER)
	# Line 343: mark_as_advanced(GDCM_USE_SYSTEM_POPPLER)
	# Line 345: option(GDCM_USE_SYSTEM_LIBXML2 "Use LibXml2" OFF)
	# Line 346: if(GDCM_USE_SYSTEM_LIBXML2)
	# Line 349: mark_as_advanced(GDCM_USE_SYSTEM_LIBXML2)
	# Line 351: if(GDCM_USE_SYSTEM_LJPEG)
	# Line 358: if(GDCM_USE_SYSTEM_CHARLS)
	# Line 365: if(GDCM_USE_SYSTEM_OPENJPEG)
	# Line 381:   option(GDCM_USE_SYSTEM_PVRG "Use system PVRG" OFF)
	# Line 382:   mark_as_advanced(GDCM_USE_SYSTEM_PVRG)
	# Line 383:   if(GDCM_USE_SYSTEM_PVRG)
	# Line 394:   option(GDCM_USE_SYSTEM_KAKADU "Use system KAKADU " ON)
	# Line 395:   mark_as_advanced(GDCM_USE_SYSTEM_KAKADU)
	# Line 396:   if(GDCM_USE_SYSTEM_KAKADU)