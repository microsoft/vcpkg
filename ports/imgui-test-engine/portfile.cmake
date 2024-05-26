vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui_test_engine
    REF "v${VERSION}"
    SHA512 809b06076fbeb544cd9544020c336f943f05bc5772df183c94dbdd5057d9b7b8718c72e5b908205cbef06c511b01f7a8e706a23aa668ca9fd12e891ef8ffb48e
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/imgui-test-engine-config.cmake.in" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES 
        implot       IMGUI_TEST_ENGINE_IMPLOT
        std-function IMGUI_TEST_ENGINE_STD_FUNCTION
)

file(REMOVE_RECURSE "${SOURCE_PATH}/imgui_test_engine/thirdparty/stb")
vcpkg_replace_string("${SOURCE_PATH}/imgui_test_engine/imgui_capture_tool.cpp" "//#define IMGUI_STB_IMAGE_WRITE_FILENAME \"my_folder/stb_image_write.h\"" "#define IMGUI_STB_IMAGE_WRITE_FILENAME <stb_image_write.h>\n#define STB_IMAGE_WRITE_STATIC")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DIMGUI_TEST_ENGINE_SKIP_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imgui_te_imconfig.h" "#define IMGUI_TEST_ENGINE_ENABLE_COROUTINE_STDTHREAD_IMPL 0" "#define IMGUI_TEST_ENGINE_ENABLE_COROUTINE_STDTHREAD_IMPL 1")

if ("implot" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imgui_te_imconfig.h" "#define IMGUI_TEST_ENGINE_ENABLE_IMPLOT 0" "#define IMGUI_TEST_ENGINE_ENABLE_IMPLOT 1")
endif()
if ("std-function" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imgui_te_imconfig.h" "#define IMGUI_TEST_ENGINE_ENABLE_STD_FUNCTION 0" "#define IMGUI_TEST_ENGINE_ENABLE_STD_FUNCTION 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/imgui_te_engine.h" "#if IMGUI_TEST_ENGINE_ENABLE_STD_FUNCTION" "#if 1")
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/imgui_test_engine/LICENSE.txt")
