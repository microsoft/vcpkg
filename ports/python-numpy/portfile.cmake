include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numpy/numpy
    REF v1.14.2
    SHA512 65b10462011e033669b700f0688df2e8630a097323fc7d72e71549fdfc2258546fe6f1317e0d51e1a0c9ab86451e0998ccbc7daa9af690652a96034571d5b76b 
    HEAD_REF master
)

set(VCPKG_PYTHON_INCLUDE_DIRS)

if("openblas" IN_LIST FEATURES)
    file(WRITE ${SOURCE_PATH}/site.cfg
        "[openblas]\n"
        "libraries = openblas\n"
        "include_dirs = ${CURRENT_INSTALLED_DIR}/include\n"
        "library_dirs = ${CURRENT_INSTALLED_DIR}/lib\n")
endif()

if("mkl" IN_LIST FEATURES)
    set(ProgramFilesx86 "ProgramFiles(x86)")
    set(INTEL_ROOT $ENV{${ProgramFilesx86}}/IntelSWTools/compilers_and_libraries/windows)
    find_path(MKL_ROOT include/mkl.h PATHS $ENV{MKLROOT} ${INTEL_ROOT}/mkl DOC "Folder contains MKL")

    file(WRITE ${SOURCE_PATH}/site.cfg
        "[mkl]\n"
        "include_dirs = ${MKL_ROOT}/include\n"
        "library_dirs = ${MKL_ROOT}/lib/intel64\n")
endif()

include(${CURRENT_INSTALLED_DIR}/share/python-setuptools/python-pip-install.cmake)
python_pip_install(SOURCE_PATH ${SOURCE_PATH})
