vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO shogun-toolbox/shogun
    REF 8f01b2b9e4de46a38bf70cdb603db75ebfd4b58b
    SHA512 24bd0e3e2a599e81432f59bd6ebc514729453cfe808541f6842dc57e2eff329e52a3e3575580bf84b2d4768209fa2624295e4e9cdcdc656dd48a8ab66bc6dbc6
    HEAD_REF master
    PATCHES
        cmake.patch
        eigen-3.4.patch
        fix-ASSERT-not-found.patch
        fix-cblas-path.patch
        fmt.patch
        syntax.patch
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_META_EXAMPLES=OFF
        -DBUILD_EXAMPLES=OFF
        -DUSE_SVMLIGHT=OFF
        -DENABLE_TESTING=OFF
        -DLICENSE_GPL_SHOGUN=OFF
        -DLIBSHOGUN_BUILD_STATIC=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ViennaCL=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_TFLogger=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_GLPK=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_CPLEX=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_ARPACK=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_Mosek=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_LpSolve=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_ColPack=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_ARPREC=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_CCache=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_CURL=TRUE
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenMP=TRUE
        -DINSTALL_TARGETS=shogun-static
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE
    # This directory is empty given the settings above
    "${CURRENT_PACKAGES_DIR}/include/shogun/mathematics/linalg/backend"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
