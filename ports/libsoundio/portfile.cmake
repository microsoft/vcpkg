string(REGEX REPLACE "^([0-9]+[.][0-9]+[.][0-9]+)[.]" "\\1-" git_tag "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrewrk/libsoundio
    REF "${git_tag}"
    SHA512 e854f066087f72438c9f014336a611d73b55a7b932747f94464477bd9f7daf9da440bad820d9c8e3d90ae3679af62a051e9645f0e0a2ddaed9726245a81f1e66
    HEAD_REF master
    PATCHES
        fix_cmakelists.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        alsa ENABLE_ALSA
        jack ENABLE_JACK
        pulseaudio ENABLE_PULSEAUDIO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DYNAMIC_LIBS=${BUILD_DYNAMIC_LIBS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_EXAMPLE_PROGRAMS=OFF
        -DBUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
        -DENABLE_COREAUDIO=${VCPKG_TARGET_IS_OSX}
        -DENABLE_WASAPI=${VCPKG_TARGET_IS_WINDOWS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/soundio/soundio.h" "defined(SOUNDIO_STATIC_LIBRARY)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
