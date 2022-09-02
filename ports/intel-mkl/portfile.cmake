# Due to the complexity involved, this package doesn't install MKL. It instead verifies that MKL is installed.
# Other packages can depend on this package to declare a dependency on MKL.
# If this package is installed, we assume that MKL is properly installed.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if (VCPKG_TARGET_IS_WINDOWS)
    set(MKL_REQUIRED_VERSION "20200000")
    set(ProgramFilesx86 "ProgramFiles(x86)")
    set(INTEL_ROOT $ENV{${ProgramFilesx86}}/IntelSWTools/compilers_and_libraries/windows)
    set(ONEMKL_ROOT $ENV{${ProgramFilesx86}}/Intel/oneAPI/mkl/latest)
    
    set(FAILURE_MESSAGE "Could not find MKL. Before continuing, please download and install MKL  (${MKL_REQUIRED_VERSION} or higher) from:"
                        "\n    https://registrationcenter.intel.com/en/products/download/3178/\n"
                        "\nAlso ensure vcpkg has been rebuilt with the latest version (v0.0.104 or later)")
else()
    set(MKL_REQUIRED_VERSION "2020.0.000")
    file(GLOB MKL_PATHS
        "$ENV{MKLROOT}"
        "${INTEL_ROOT}/mkl"
        "${INTEL_ONEAPI_MKL_ROOT}"
        "${ONEAPI_ROOT}/mkl"
        "/opt/intel/compilers_and_libraries_*.*.*"
        "/opt/intel/oneapi/mkl"
        "/opt/intel/mkl"
    )
    foreach(MKL_PATH ${MKL_PATHS})
        get_filename_component(CURRENT_VERSION ${MKL_PATH} NAME)
        string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+$" VERSION_NUM ${CURRENT_VERSION})
        if (IS_DIRECTORY ${MKL_PATH} AND VERSION_NUM)
            if (VERSION_NUM VERSION_GREATER_EQUAL ${MKL_REQUIRED_VERSION})
                set(INTEL_ROOT ${MKL_PATH}/linux)
                message("Fond Suitable version ${VERSION_NUM}")
                break()
            endif()
        endif()
    endforeach()
    
    set(FAILURE_MESSAGE "Could not find MKL. Before continuing, please install MKL (${MKL_REQUIRED_VERSION} or higher) using the system package manager"
                        "See https://software.intel.com/content/www/us/en/develop/articles/installing-intel-free-libs-and-python-apt-repo.html"
                        "\nAlso ensure vcpkg has been rebuilt with the latest version (v0.0.104 or later)")
endif()

find_path(MKL_ROOT mkl.h
    PATHS
    $ENV{MKLROOT}/include
    ${INTEL_ROOT}/mkl/include
    $ENV{ONEAPI_ROOT}/mkl/latest/include
    ${ONEMKL_ROOT}/include
    /usr/include/mkl
    DOC
    "Folder contains MKL"
)

if (MKL_ROOT STREQUAL "MKL_ROOT-NOTFOUND")
    message(FATAL_ERROR ${FAILURE_MESSAGE})
endif()

# file(STRINGS ${MKL_ROOT}/include/mkl_version.h MKL_VERSION_DEFINITION REGEX "__INTEL_MKL((_MINOR)|(_UPDATE))?__")
# string(REGEX MATCHALL "([0-9]+)" MKL_VERSION ${MKL_VERSION_DEFINITION})
# list(GET MKL_VERSION 0 MKL_VERSION_MAJOR)
# list(GET MKL_VERSION 1 MKL_VERSION_MINOR)
# list(GET MKL_VERSION 2 MKL_VERSION_UPDATE)

file(STRINGS "${MKL_ROOT}/mkl_version.h" MKL_VERSION_DEFINITION REGEX "INTEL_MKL_VERSION")
string(REGEX MATCH "([0-9]+)" MKL_VERSION ${MKL_VERSION_DEFINITION})

if (MKL_VERSION VERSION_LESS MKL_REQUIRED_VERSION)
    message(FATAL_ERROR "MKL ${MKL_VERSION} is found but ${MKL_REQUIRED_VERSION} is required. Please download and install a more recent version of MKL from:"
                        "\n    https://software.intel.com/content/www/us/en/develop/tools/oneapi/base-toolkit.html\n")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/mkl/vcpkg-cmake-wrapper.cmake" @ONLY)
