vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RapidAI/RapidOcrOnnx
    REF de302828f42b087783b094c1f2fcb4507894c3d8
    SHA512 9d05b8e38503bd8866c5618c8bb00bba89e2631543182bf6960905b611b4627070e0bb5bc22c8c034baacedec19acc905c761b8b88389bf5ca580eee55561d97
    HEAD_REF main
    PATCHES
        # Still present on main: DbNet/CrnnNet/AngleNet leave Ort::Session*
        # indeterminate until initModel() and delete it in the destructor.
        # OcrLite always constructs those nets via pImpl, so a default
        # OcrLite still faults on destroy. Upstream is unmaintained.
        fix-uninitialized-session.patch
        use-vcpkg-deps.patch
        cmake-system-deps.patch
)

# Clipper is supplied by the polyclipping port. The CLI/JNI sources are
# excluded from the library target by cmake-system-deps.patch.
file(REMOVE
    "${SOURCE_PATH}/include/clipper.hpp"
    "${SOURCE_PATH}/src/clipper.cpp"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-rapidocr-config.cmake.in"
     DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOCR_OUTPUT=CLIB
        -DOCR_BENCHMARK=OFF
        -DOCR_ONNX=CPU
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
