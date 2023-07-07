if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-telemetry/opentelemetry-cpp-contrib
    REF 49a42a3bd950d3359f0b3921c13f6adc7cfc793a  # Maps to 2.0.0
    HEAD_REF main
    SHA512 a2d621363860b0ff391ddf53cb2a293c7652c17d10e99bd9d085969df64a8f13b32e550124879833dd43f9e9428a422bc1ae7ca4a737722e7b24be886d6b576d
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/exporters/fluentd"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
