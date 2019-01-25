export CURRENT_PACKAGES_DIR=$1

export PYTHON_BIN_PATH=/usr/bin/python
export USE_DEFAULT_PYTHON_LIB_PATH=1
export TF_NEED_JEMALLOC=1
export TF_NEED_KAFKA=0
export TF_NEED_OPENCL_SYCL=0
export TF_NEED_AWS=0
export TF_NEED_GCP=0
export TF_NEED_HDFS=0
export TF_NEED_S3=0
export TF_ENABLE_XLA=1
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_OPENCL=0
export TF_NEED_MPI=0
export TF_NEED_TENSORRT=0
export TF_NEED_NGRAPH=0
export TF_NEED_IGNITE=0
export TF_NEED_ROCM=0
export TF_SET_ANDROID_WORKSPACE=0
export TF_DOWNLOAD_CLANG=0
export TF_NCCL_VERSION=2.3
export NCCL_INSTALL_PATH=/usr
export CC_OPT_FLAGS="-march=x86-64"
export TF_NEED_CUDA=0

./configure

#https://github.com/tensorflow/tensorflow/issues/24527
bazel build \
    --config=opt \
    --incompatible_package_name_is_a_function=false \
    //tensorflow:libtensorflow_cc.so \
    //tensorflow:install_headers

mkdir -p ${CURRENT_PACKAGES_DIR}/include/
chmod 755 ${CURRENT_PACKAGES_DIR}/include/
cp -rp bazel-genfiles/tensorflow/include ${CURRENT_PACKAGES_DIR}/

mkdir -p ${CURRENT_PACKAGES_DIR}/include/tensorflow-etc/
chmod 755 ${CURRENT_PACKAGES_DIR}/include/tensorflow-etc/
chmod 755 ${CURRENT_PACKAGES_DIR}/include/tensorflow-etc/external/
cp -rp bazel-genfiles/tensorflow/include/tensorflow/external \
    ${CURRENT_PACKAGES_DIR}/include/tensorflow-etc/

mkdir -p ${CURRENT_PACKAGES_DIR}/lib
chmod 755 ${CURRENT_PACKAGES_DIR}/lib
for i in bazel-bin/tensorflow/*.so; do
    install -m755  $i ${CURRENT_PACKAGES_DIR}/lib/;
done;
