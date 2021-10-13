vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtaudio
    REF bc7ad66581947f810ff4460396bbbd1846b1e7c8
    SHA512 ef5a41df15a8486550fb791ac21fcee4ecbf726fe9e91a56fcdd437cd554ea242f08c1061a9c6d5c261d721d86fbbcb32ce64db030976150862ed42a40137fc7
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

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRTAUDIO_STATIC_MSVCRT=${RTAUDIO_STATIC_MSVCRT}
        -DRTAUDIO_API_JACK=OFF
        -DRTAUDIO_API_PULSE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
