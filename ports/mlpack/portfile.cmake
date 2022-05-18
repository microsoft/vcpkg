vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF 7ae9ddda86c1751b6509ceb48b27d182feaae439 # 3.4.1
    SHA512 db68c16b80af7037ac562f93775b6262f1552fbc89daa0c621075e2ff70a8306523da8eb74e33ac15ba34c9ccef8f2746bd1e4efa7c280a5be77b53c69d3f9a1
    HEAD_REF master
    PATCHES
        cmakelists.patch
        fix-configure-error.patch
        fix-test-dependency.patch
        fix-dependencies.patch
)

file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindACML.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindACMLMP.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindARPACK.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindBLAS.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindCBLAS.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindCLAPACK.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindLAPACK.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindMKL.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/ARMA_FindOpenBLAS.cmake")
file(REMOVE "${SOURCE_PATH}/CMake/FindArmadillo.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   BUILD_CLI_EXECUTABLES
        openmp  USE_OPENMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_STB_IMAGE=OFF
        -DDOWNLOAD_ENSMALLEN=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mlpack)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES
        mlpack_adaboost
        mlpack_approx_kfn
        mlpack_cf
        mlpack_dbscan
        mlpack_decision_stump
        mlpack_decision_tree
        mlpack_det
        mlpack_emst
        mlpack_fastmks
        mlpack_gmm_generate
        mlpack_gmm_probability
        mlpack_gmm_train
        mlpack_hmm_generate
        mlpack_hmm_loglik
        mlpack_hmm_train
        mlpack_hmm_viterbi
        mlpack_hoeffding_tree
        mlpack_kde
        mlpack_kernel_pca
        mlpack_kfn
        mlpack_kmeans
        mlpack_knn
        mlpack_krann
        mlpack_lars
        mlpack_linear_regression
        mlpack_linear_svm
        mlpack_lmnn
        mlpack_local_coordinate_coding
        mlpack_logistic_regression
        mlpack_lsh
        mlpack_mean_shift
        mlpack_nbc
        mlpack_nca
        mlpack_nmf
        mlpack_pca
        mlpack_perceptron
        mlpack_preprocess_binarize
        mlpack_preprocess_describe
        mlpack_preprocess_imputer
        mlpack_preprocess_scale
        mlpack_preprocess_split
        mlpack_radical
        mlpack_random_forest
        mlpack_range_search
        mlpack_softmax_regression
        mlpack_sparse_coding
        mlpack_image_converter
        mlpack_bayesian_linear_regression
        mlpack_preprocess_one_hot_encoding
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
