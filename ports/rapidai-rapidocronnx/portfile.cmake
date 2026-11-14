vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RapidAI/RapidOcrOnnx
    REF 675e73fe4c8b9e1d0be558bb5959a1b37696ed90
    SHA512 b126aa3906c05a14eec596a543893554f241356bf426e864e320944fd5526f5d21677ca91f6115065e6ed6116b30516ecc02e20888747c51e5b5cffb54cedb67
    HEAD_REF main
    PATCHES
        use-vcpkg-deps.patch
        fix-c-api-and-exports.patch
        cmake-system-deps.patch
)

# Clipper comes from the polyclipping port.
file(REMOVE
    "${SOURCE_PATH}/include/clipper.hpp"
    "${SOURCE_PATH}/src/clipper.cpp"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-rapidocronnx-config.cmake.in"
     DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOCR_OUTPUT=CLIB
        -DOCR_ONNX=CPU
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-rapidocronnx
    CONFIG_PATH share/unofficial-rapidocronnx
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    foreach(header IN ITEMS OcrLite.h OcrLiteCApi.h)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rapidocronnx/${header}"
            "!defined(RAPIDOCR_STATIC)" "0")
    endforeach()
endif()

file(INSTALL "${SOURCE_PATH}/models/ppocr_keys_v1.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/models")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
