include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CMAKE_DISABLE_FIND_PACKAGE_BLAS 0)
else()
    set(CMAKE_DISABLE_FIND_PACKAGE_BLAS 1)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shogun-toolbox/shogun
    REF ab274e7ab6bf24dd598c1daf1e626cb686d6e1cc
    SHA512 fb90e5bf802c6fd59bf35ab7bbde5e8cfcdc5d46c69c52097140b30c6b29e28b8341dd1ece7f8a1f9d9123f4bc06d44d288584ce7dfddccf3d33fe05106884ae
    HEAD_REF master
    PATCHES
        cmake.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/external)
file(MAKE_DIRECTORY ${SOURCE_PATH}/cmake/external)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/MSDirent.cmake DESTINATION ${SOURCE_PATH}/cmake/external)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(${PYTHON3_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_META_EXAMPLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DUSE_SVMLIGHT=OFF
        -DENABLE_TESTING=OFF
        -DLICENSE_GPL_SHOGUN=OFF
        -DLIBSHOGUN_BUILD_STATIC=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_JSON=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_ViennaCL=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_TFLogger=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_GLPK=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_CPLEX=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_ARPACK=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_Mosek=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_LpSolve=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_ColPack=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_ARPREC=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_Ctags=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_CCache=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_LAPACK=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_CURL=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_BLAS=${CMAKE_DISABLE_FIND_PACKAGE_BLAS}

        -DINSTALL_TARGETS=shogun-static
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shogun)

file(REMOVE_RECURSE
    # This directory is empty given the settings above
    ${CURRENT_PACKAGES_DIR}/include/shogun/mathematics/linalg/backend
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/shogun)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shogun/COPYING ${CURRENT_PACKAGES_DIR}/share/shogun/copyright)
