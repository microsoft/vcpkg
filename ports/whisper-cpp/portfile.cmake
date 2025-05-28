vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/whisper.cpp
    REF v${VERSION}
    SHA512 35efd976f60261e108972e3af7b322d723e36be30f5265db3be63752caaed0b52b9da3ece02975da2b83ff30f1eb32663e77fbaaf15f3037e35a525939071c0b
    HEAD_REF master
    PATCHES
        0001-ggml-alias.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/ggml")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DWHISPER_USE_SYSTEM_GGML=ON
      -DWHISPER_CCACHE=OFF
      -DWHISPER_BUILD_TESTS=OFF
      -DWHISPER_BUILD_EXAMPLES=OFF
      -DWHISPER_ALL_WARNINGS=OFF
      ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME whisper CONFIG_PATH "lib/cmake/whisper")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE MATCHES "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/whisper/whisper-config.cmake"
        "set_and_check(WHISPER_BIN_DIR     \"\${PACKAGE_PREFIX_DIR}/bin\")"
        ""
        IGNORE_UNCHANGED
    )
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/whisper/whisper-config.cmake"
    "add_library(whisper UNKNOWN IMPORTED)"
    "if (NOT TARGET whisper)
    add_library(whisper UNKNOWN IMPORTED)
endif()
"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/models/convert-pt-to-ggml.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if (VCPKG_LIBRARY_LINKAGE MATCHES "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")