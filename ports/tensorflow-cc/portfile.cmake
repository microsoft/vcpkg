vcpkg_fail_port_install(ON_ARCH "x86" "arm" ON_TARGET "UWP")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

set(TF_LIB_SUFFIX "_cc")
set(TF_PORT_SUFFIX "-cc")
set(TF_INCLUDE_DIRS "${CURRENT_INSTALLED_DIR}/include/tensorflow-external ${CURRENT_INSTALLED_DIR}/include/tensorflow-external/src")
list(APPEND CMAKE_MODULE_PATH "${CURRENT_INSTALLED_DIR}/share/tensorflow-common")
include(tensorflow-common)

file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bazel-bin/tensorflow/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/tensorflow-external")
