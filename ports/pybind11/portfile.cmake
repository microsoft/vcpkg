include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pybind11-2.0.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/pybind/pybind11/archive/v2.1.0.tar.gz"
    FILENAME "pybind11-2.1.0.tar.gz"
    SHA512 2f74dcd2b82d8e41da7db36351284fe04511038bec66bdde820da9c0fce92f6d2c5aeb2e48264058a91a775a1a6a99bc757d26ebf001de3df4183d700d46efa1
)
vcpkg_extract_source_archive(${ARCHIVE})

# link the MSVC runtime statically if set.
if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CRUNTIME /MD)
else()
    set(CRUNTIME /MT)
endif()

#STREQUAL empty here means the enviroment variable is not defined.
if(NOT $ENV{PYTHON} STREQUAL "")
    set(PYTHON_VER $ENV{PYTHON})
else()
    message(FATAL_ERROR "You must set the PYTHON environment variable, eg. set PYTHON=3.5 or export PYTHON=3.5")
endif()

if(NOT $ENV{CPP} STREQUAL "")
    set(CPP_STD $ENV{CPP})
else()
    message(FATAL_ERROR "You must set the CPP environment variable, eg. set CPP=11 or export CPP=11.")
endif()
message(STATUS "Using C++${CPP_STD} and Python ${PYTHON_VER}")
vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DPYBIND11_PYTHON_VERSION=${PYTHON_VER}
            -DPYBIND11_CPP_STANDARD=${CPP_STD}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)


# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pybind11/copyright)