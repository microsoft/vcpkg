include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF a8af4882af5e163ae8c8023653c66c8914ac1c22 # 3.2.2
    SHA512 879dd24f6cface3e6e1a0990e912ca4463060725c7c105e1e7d228c90123b1f44728cbe1ae327fa20e0e4981626a5d1eb2c411257899ef849c9600891616eed4
    HEAD_REF master
    PATCHES
        cmakelists.patch
        blas_lapack.patch
)

file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindACML.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindACMLMP.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindARPACK.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindBLAS.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindCBLAS.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindCLAPACK.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindLAPACK.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindMKL.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/ARMA_FindOpenBLAS.cmake)
file(REMOVE ${SOURCE_PATH}/CMake/FindArmadillo.cmake)

set(BUILD_TOOLS OFF)
if("tools" IN_LIST FEATURES)
    set(BUILD_TOOLS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=${BUILD_TOOLS}
        -DBUILD_CLI_EXECUTABLES=${BUILD_TOOLS}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/mlpack RENAME copyright)

if(BUILD_TOOLS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
    file(GLOB MLPACK_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(COPY ${MLPACK_TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${MLPACK_TOOLS})
    file(GLOB MLPACK_TOOLS_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${MLPACK_TOOLS_DEBUG})
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
