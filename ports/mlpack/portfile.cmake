# Became a header-only library since 4.0.0
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF 28eb1858c59e4469da0e9689663a45fc140af9c4 # 4.0.0
    SHA512 b33aa5df48c9f0e5a5fac7bfb69fd2c64bc01f1ba0ae22990774e1805881c60e4652d2f23b6c95627da1a20e39ee6a90e327fdaa6d1e00bac8986dcecc15a89a
    HEAD_REF master
)


# Copy the header files
set(mlpack_HEADERS 
	"${SOURCE_PATH}/src/mlpack/base.hpp"
	"${SOURCE_PATH}/src/mlpack/prereqs.hpp"
	"${SOURCE_PATH}/src/mlpack/core.hpp"
	"${SOURCE_PATH}/src/mlpack/namespace_compat.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/adaboost.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/amf.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/ann.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/approx_kfn.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/bayesian_linear_regression.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/bias_svd.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/block_krylov_svd.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/cf.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/dbscan.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/decision_tree.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/det.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/emst.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/fastmks.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/gmm.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/hmm.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/hoeffding_trees.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/kde.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/kernel_pca.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/kmeans.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/lars.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/linear_regression.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/lmnn.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/local_coordinate_coding.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/logistic_regression.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/lsh.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/matrix_completion.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/mean_shift.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/naive_bayes.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/nca.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/neighbor_search.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/pca.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/perceptron.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/quic_svd.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/radical.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/random_forest.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/randomized_svd.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/range_search.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/rann.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/regularized_svd.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/reinforcement_learning.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/softmax_regression.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/sparse_autoencoder.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/sparse_coding.hpp"
	"${SOURCE_PATH}/src/mlpack/methods/svdplusplus.hpp")	

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/mlpack/methods")

foreach(HEADER ${mlpack_HEADERS})
	string(REPLACE "${SOURCE_PATH}/src" "${CURRENT_PACKAGES_DIR}/include" OUT_HEADER "${HEADER}")
    file(RENAME "${HEADER}" "${OUT_HEADER}")
endforeach(HEADER ${mlpack_HEADERS})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")

