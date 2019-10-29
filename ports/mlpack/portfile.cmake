include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF 214bb060290c3ba5f83a05784538346d212a4f9f # 3.2.1
    SHA512 f45a922d0fcf6ca3cc66632eb0429fb75a2c1ec6f402c2dc45de2f16822cbf2b7bc2ade56eebbdcd4b270daf86751ddbf2f3012c92179d5a9a749339b741c584
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
