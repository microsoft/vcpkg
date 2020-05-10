find_program(GIT NAMES git git.cmd)
#set(GIT_URL "https://github.com/IntelPython/numpy")
set(GIT_URL "https://github.com/numpy/numpy")
#set(GIT_REV v1.16.3)#intel/1.16.3)
set(GIT_REV v1.18.4)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
      COMMAND ${GIT} clone --recurse-submodules -q --depth=1 --branch=${GIT_REV} ${GIT_URL} ${SOURCE_PATH}
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME clone
    )
    message(STATUS "Fetching submodules")
    vcpkg_execute_required_process(
      COMMAND ${GIT} submodule update --init --recursive
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME submodules
    )
endif()

file(REMOVE ${SOURCE_PATH}/site.cfg)

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

vcpkg_build_python(SOURCE_PATH ${SOURCE_PATH})
configure_file(${CURRENT_PORT_DIR}/site.cfg.in ${PYTHON_PACKAGES_PATH}/numpy/distutils/site.cfg)
