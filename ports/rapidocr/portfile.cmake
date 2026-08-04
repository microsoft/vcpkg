vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RapidAI/RapidOcrOnnx
    REF "${VERSION}"
    SHA512 d00256cccb9d1661e508d2ed416fd348c2cc3447c70967cc48f77ec29b7859086e5fdc6a83289f5e1efccd0dcf393442a669a6461f675d87feeda9dbe2363aee
    HEAD_REF main
)

# vcpkg onnxruntime installs headers under include/onnxruntime/ (and also
# include/onnxruntime/core/session/). Upstream already uses:
#   #include <onnxruntime/core/session/onnxruntime_cxx_api.h>
# which resolves correctly — no include rewrite needed.

# Upstream CMake expects vendored static OpenCV/ORT trees. Use our CMake.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-rapidocr-config.cmake.in"
     DESTINATION "${SOURCE_PATH}")

set(RAPIDOCR_BUILD_TOOLS OFF)
if("tools" IN_LIST FEATURES)
    set(RAPIDOCR_BUILD_TOOLS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DRAPIDOCR_BUILD_TOOLS=${RAPIDOCR_BUILD_TOOLS}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-rapidocr
    CONFIG_PATH share/unofficial-rapidocr
)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES RapidOcrOnnx AUTO_CLEAN)
endif()

if(EXISTS "${SOURCE_PATH}/models/ppocr_keys_v1.txt")
    file(INSTALL "${SOURCE_PATH}/models/ppocr_keys_v1.txt"
         DESTINATION "${CURRENT_PACKAGES_DIR}/share/rapidocr/models")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
