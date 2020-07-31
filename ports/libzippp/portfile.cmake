
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ctabin/libzippp
    REF fb07ca80ebda0576366619b87364b4b3a94426df
    SHA512 c75518d0dba43ca5ae617569c0e3105af4f903a1226bdae100ee0770b4745ce4c889d29788bd2d75e7c8b556a5c339c0610170a620081d67a86cf6639e9e7fb2
    HEAD_REF libzippp-v3.1-1.6.1 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBZIPPP_BUILD_TESTS=OFF
    OPTIONS_DEBUG
        -DLIBZIPPP_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

if(WIN32)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake/libzippp")
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH "share/libzippp")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzippp RENAME copyright)
