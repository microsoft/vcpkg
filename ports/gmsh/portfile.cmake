string(REPLACE "." "_" UNDERSCORES_VERSION "${VERSION}")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.onelab.info
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gmsh/gmsh
    REF "${PORT}_${UNDERSCORES_VERSION}"
    SHA512 af2574ec3aadfddeedf981faced20a6736be06fe30c7670b682837612ca5a42248444f7a782ca5e75556cb957b5cf4467d5e972ba3f60559cc719690e73f3dca
    HEAD_REF master
    PATCHES fix-install.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opencascade ENABLE_OCC
        opencascade ENABLE_OCC_CAF
        opencascade ENABLE_OCC_TBB
        mpi         ENABLE_MPI
        zipper      ENABLE_ZIPPER
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_BUILD_LIB=${BUILD_LIB}
        -DENABLE_BUILD_SHARED=${BUILD_SHARED}
        -DENABLE_MSVC_STATIC_RUNTIME=${STATIC_RUNTIME}
        -DGMSH_RELEASE=ON
        -DENABLE_PACKAGE_STRIP=ON
        -DENABLE_SYSTEM_CONTRIB=ON
        # Not implement
        -DENABLE_GRAPHICS=OFF # Requires mesh, post, plugins and onelab
        -DENABLE_POST=OFF
        -DENABLE_PLUGINS=OFF
        -DENABLE_MESH=OFF
        -DENABLE_PARSER=OFF
        -DENABLE_PROFILE=OFF
        -DENABLE_PRIVATE_API=OFF
        -DENABLE_QUADMESHINGTOOLS=OFF
        -DENABLE_PRO=OFF
        -DENABLE_TOUCHBAR=OFF
        -DENABLE_VISUDEV=OFF
        -DENABLE_BLAS_LAPACK=OFF
        -DENABLE_CAIRO=OFF
        -DENABLE_CGNS=OFF
        -DENABLE_CGNS_CPEX0045=OFF
        -DENABLE_EIGEN=OFF
        -DENABLE_GMP=OFF
        -DENABLE_OPENMP=OFF
        -DENABLE_POPPLER=OFF
        -DENABLE_WRAP_JAVA=OFF
        -DENABLE_WRAP_PYTHON=OFF
        # Requies dependencies which not included in vcpkg yet
        -DENABLE_3M=OFF
        -DENABLE_ALGLIB=OFF
        -DENABLE_ANN=OFF
        -DENABLE_BAMG=OFF
        -DENABLE_BLOSSOM=OFF
        -DENABLE_BUILD_DYNAMIC=OFF # Needs gfortran
        -DENABLE_FLTK=OFF # Needs executable fltk-config
        -DENABLE_DINTEGRATION=OFF
        -DENABLE_GEOMETRYCENTRAL=OFF
        -DENABLE_DOMHEX=OFF
        -DENABLE_GETDP=OFF
        -DENABLE_GMM=OFF
        -DENABLE_HXT=OFF
        -DENABLE_KBIPACK=OFF
        -DENABLE_MATHEX=OFF
        -DENABLE_MED=OFF
        -DENABLE_METIS=OFF
        -DENABLE_MMG=OFF
        -DENABLE_MPEG_ENCODE=OFF
        -DENABLE_MUMPS=OFF
        -DENABLE_NUMPY=OFF
        -DENABLE_NETGEN=OFF
        -DENABLE_PETSC4PY=OFF
        -DENABLE_ONELAB_METAMODEL=OFF
        -DENABLE_ONELAB=OFF
        -DENABLE_OPENACC=OFF
        -DENABLE_OPTHOM=OFF
        -DENABLE_OSMESA=OFF
        -DENABLE_P4EST=OFF
        -DENABLE_PETSC=OFF
        -DENABLE_QUADTRI=OFF
        -DENABLE_REVOROPT=OFF
        -DENABLE_SLEPC=OFF
        -DENABLE_SOLVER=OFF
        -DENABLE_TCMALLOC=OFF
        -DENABLE_VOROPP=OFF
        -DENABLE_WINSLOWUNTANGLER=OFF
        # experimental
        -DENABLE_BUILD_ANDROID=OFF
        -DENABLE_BUILD_IOS=OFF

        -DENABLE_OS_SPECIFIC_INSTALL=OFF # Needs system permission
        -DENABLE_RPATH=OFF # Should use dependencies in vcpkg
        -DENABLE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_tools(TOOL_NAMES gmsh AUTO_CLEAN)

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-gmsh")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
