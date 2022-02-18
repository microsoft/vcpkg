# Due to the complexity involved, this package doesn't install MKL. It instead verifies that MKL is installed.
# Other packages can depend on this package to declare a dependency on MKL.
# If this package is installed, we assume that MKL is properly installed.

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(MKL_REQUIRED_VERSION "20200000")

set(ProgramFilesx86 "ProgramFiles(x86)")
set(INTEL_ROOT $ENV{${ProgramFilesx86}}/IntelSWTools/compilers_and_libraries/windows)
set(ONEMKL_ROOT $ENV{${ProgramFilesx86}}/Intel/oneAPI/mkl/latest)

find_path(MKL_ROOT include/mkl.h
    PATHS
    $ENV{MKLROOT}
    ${INTEL_ROOT}/mkl
    $ENV{ONEAPI_ROOT}/mkl/latest
    ${ONEMKL_ROOT}
    DOC
    "Folder contains MKL")

if (MKL_ROOT STREQUAL "MKL_ROOT-NOTFOUND")
    message(FATAL_ERROR "Could not find MKL. Before continuing, please download and install MKL  (${MKL_REQUIRED_VERSION} or higher) from:"
                        "\n    https://registrationcenter.intel.com/en/products/download/3178/\n"
                        "\nAlso ensure vcpkg has been rebuilt with the latest version (v0.0.104 or later)")
endif()

# file(STRINGS ${MKL_ROOT}/include/mkl_version.h MKL_VERSION_DEFINITION REGEX "__INTEL_MKL((_MINOR)|(_UPDATE))?__")
# string(REGEX MATCHALL "([0-9]+)" MKL_VERSION ${MKL_VERSION_DEFINITION})
# list(GET MKL_VERSION 0 MKL_VERSION_MAJOR)
# list(GET MKL_VERSION 1 MKL_VERSION_MINOR)
# list(GET MKL_VERSION 2 MKL_VERSION_UPDATE)

file(STRINGS ${MKL_ROOT}/include/mkl_version.h MKL_VERSION_DEFINITION REGEX "INTEL_MKL_VERSION")
string(REGEX MATCH "([0-9]+)" MKL_VERSION ${MKL_VERSION_DEFINITION})

if (MKL_VERSION LESS MKL_REQUIRED_VERSION)
    message(FATAL_ERROR "MKL ${MKL_VERSION} is found but ${MKL_REQUIRED_VERSION} is required. Please download and install a more recent version of MKL from:"
                        "\n    https://registrationcenter.intel.com/en/products/download/3178/\n")
endif()
