vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cudnn-frontend
    REF "v${VERSION}"
    SHA512 2d50fbedc1d2f488275aedce84893447a025d4c00b9e8609c4004b2eb0525480a348835d0e8b2784499d80d0c63d75bb1430741cb06c3652da8dd72b822489fa
    HEAD_REF main
)
file(REMOVE_RECURSE "${SOURCE_PATH}/include/cudnn_frontend/thirdparty")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCUDNN_FRONTEND_FETCH_PYBINDS_IN_CMAKE=OFF
        -DCUDNN_FRONTEND_BUILD_TESTS=OFF
        -DCUDNN_FRONTEND_BUILD_SAMPLES=OFF
        -DCUDNN_FRONTEND_SKIP_JSON_LIB=OFF
    MAYBE_UNUSED_VARIABLES
        CUDNN_FRONTEND_FETCH_PYBINDS_IN_CMAKE
)
vcpkg_cmake_install()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/cudnn_frontend_utils.h"
    "\"cudnn_frontend/thirdparty/nlohmann/json.hpp\""
    "<nlohmann/json.hpp>"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
