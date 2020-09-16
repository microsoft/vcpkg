vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF a8af4882af5e163ae8c8023653c66c8914ac1c22 # 3.2.2
    SHA512 879dd24f6cface3e6e1a0990e912ca4463060725c7c105e1e7d228c90123b1f44728cbe1ae327fa20e0e4981626a5d1eb2c411257899ef849c9600891616eed4
    HEAD_REF master
    PATCHES
        cmakelists.patch
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

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools     BUILD_CLI_EXECUTABLES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_STB_IMAGE=OFF
        -DDOWNLOAD_ENSMALLEN=OFF
        -DBUILD_PYTHON_BINDINGS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

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
    )
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
