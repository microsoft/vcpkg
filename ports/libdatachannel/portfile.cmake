vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF v0.9.0
    SHA512 dd03005c65c6f6188804f2a7d9cb2edb6d83ff952fc000708324b5251bb41682eecf388496ab1c9de5796a92f83f95c1e9eba0b938c8d978f6af687ba99fa878
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    no-ws NO_WEBSOCKET
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(FILE "${SOURCE_PATH}/CMakeLists.txt")
    file(READ ${FILE} _contents)
    string(REPLACE "add_library(datachannel SHARED" "add_library(datachannel STATIC" _contents "${_contents}")
    file(WRITE ${FILE} "${_contents}")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNO_EXAMPLES=ON
        -DNO_TESTS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/libdatachannel)
vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})