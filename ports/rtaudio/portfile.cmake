vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtaudio
    REF c9bf99d414cf81d19ef0ddd00212a4a58ccd99c6
    SHA512 6dc0025288cbf09f21862be6093ad77b950e6af03ea7e5aea3a9f6c322d957897c0d6206636225bd439c05b5a13d53df3ef9a9f1a9ea5d3012bee06c1a62c9f0
    HEAD_REF master
)

if(VCPKG_HOST_IS_LINUX)
    message(WARNING "rtaudio requires ALSA on Linux; this is available on ubuntu via apt install libasound2-dev")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(RTAUDIO_STATIC_MSVCRT ON)
else()
    set(RTAUDIO_STATIC_MSVCRT OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asio  RTAUDIO_API_ASIO
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRTAUDIO_STATIC_MSVCRT=${RTAUDIO_STATIC_MSVCRT}
        -DRTAUDIO_API_JACK=OFF
        -DRTAUDIO_API_PULSE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
