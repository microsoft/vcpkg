vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RapidAI/RapidOcrOnnx
    REF "${VERSION}"
    SHA512 d00256cccb9d1661e508d2ed416fd348c2cc3447c70967cc48f77ec29b7859086e5fdc6a83289f5e1efccd0dcf393442a669a6461f675d87feeda9dbe2363aee
    HEAD_REF main
    PATCHES
        # Upstream 1.2.3: DbNet/CrnnNet/AngleNet leave Ort::Session* indeterminate
        # until initModel() runs, and their destructors delete it unconditionally,
        # so destroying a default-constructed OcrLite faults. Reported upstream.
        fix-uninitialized-session.patch
)

# vcpkg installs the ONNX Runtime public wrapper under include/onnxruntime,
# while upstream includes it from the source-tree root. Use the installed API.
file(GLOB_RECURSE RAPIDOCR_CODE "${SOURCE_PATH}/include/*.h" "${SOURCE_PATH}/src/*.cpp")
foreach(source_file IN LISTS RAPIDOCR_CODE)
    file(READ "${source_file}" contents)
    string(REPLACE "onnxruntime/core/session/onnxruntime_cxx_api.h"
                   "onnxruntime/onnxruntime_cxx_api.h" contents "${contents}")
    string(REPLACE "\"clipper.hpp\"" "<polyclipping/clipper.hpp>" contents "${contents}")
    # This is a static-only port, so the C API must not present __declspec to
    # consumers. Upstream keys the storage class off __CLIB__, which a consumer
    # compiling against the installed headers has no way to define, leaving it
    # with dllimport declarations and unresolved __imp_Ocr* symbols.
    string(REPLACE "#define _QM_OCR_API __declspec(dllexport)"
                   "#define _QM_OCR_API" contents "${contents}")
    string(REPLACE "#define _QM_OCR_API __declspec(dllimport)"
                   "#define _QM_OCR_API" contents "${contents}")
    file(WRITE "${source_file}" "${contents}")
endforeach()

# Clipper is supplied by the polyclipping port; do not package or compile the
# vendored copy. The CLI is intentionally not packaged, so getopt is unused.
file(REMOVE "${SOURCE_PATH}/include/clipper.hpp" "${SOURCE_PATH}/src/clipper.cpp")

# Upstream CMake expects vendored static OpenCV/ORT trees. Use our CMake.
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-rapidocr-config.cmake.in"
     DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-rapidocr
    CONFIG_PATH share/unofficial-rapidocr
)

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
