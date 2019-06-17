include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shogun-toolbox/shogun
    REF shogun_6.1.3
    SHA512 11aeed456b13720099ca820ab9742c90ce4af2dc049602a425f8c44d2fa155327c7f1d3af2ec840666f600a91e75902d914ffe784d76ed35810da4f3a5815673
    HEAD_REF master
    PATCHES
        cmake.patch
        use_proper_cmake_symbol.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/external)
file(MAKE_DIRECTORY ${SOURCE_PATH}/cmake/external)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/MSDirent.cmake DESTINATION ${SOURCE_PATH}/cmake/external)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CMAKE_DISABLE_FIND_PACKAGE_BLAS 0)
else()
    set(CMAKE_DISABLE_FIND_PACKAGE_BLAS 1)
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CMAKE_SYSTEM_PROCESSOR "__x86_64__")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(CMAKE_SYSTEM_PROCESSOR "__i386__")
    endif()
endif()

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

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
        # Conflicting definitions in OpenBLAS and Eigen
        -DENABLE_EIGEN_LAPACK=OFF

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
        -DCMAKE_DISABLE_FIND_PACKAGE_BLAS=${CMAKE_DISABLE_FIND_PACKAGE_BLAS}

        -DINSTALL_TARGETS=shogun-static
        -DCMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}
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
