vcpkg_fail_port_install(ON_ARCH "x86" "arm" ON_TARGET "UWP")

set(TF_LIB_SUFFIX "_cc")
set(TF_PORT_SUFFIX "-cc")
set(TF_INCLUDE_DIRS "${INSTALL_PREFIX}/${TARGET_TRIPLET}/include/tensorflow-external
		${INSTALL_PREFIX}/${TARGET_TRIPLET}/include/tensorflow-external/src")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../tensorflow-common")
include(tensorflow-common)

file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/tensorflow-external)
