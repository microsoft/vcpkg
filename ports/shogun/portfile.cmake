if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message("shogun only supports static library linkage")
    set(VCPKG_LIBRARY_LINKAGE "static")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shogun-toolbox/shogun
    REF shogun_6.1.3
    SHA512 11aeed456b13720099ca820ab9742c90ce4af2dc049602a425f8c44d2fa155327c7f1d3af2ec840666f600a91e75902d914ffe784d76ed35810da4f3a5815673
    HEAD_REF master
)

file(REMOVE_RECURSE ${SOURCE_PATH}/cmake/external)
file(MAKE_DIRECTORY ${SOURCE_PATH}/cmake/external)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/MSDirent.cmake DESTINATION ${SOURCE_PATH}/cmake/external)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_META_EXAMPLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DUSE_SVMLIGHT=OFF
        -DENABLE_TESTING=OFF
        -DLICENSE_GPL_SHOGUN=OFF
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
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE

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
