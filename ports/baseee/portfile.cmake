# Download File From Github
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chhdao/baseee
    REF 9d2618d1b41b178bf33421d674bf53fd85f0abb1
    SHA512 54dd03f5d70219f7e322c792cb1774bfbd0f837e4a1f964d97240b0c9eff8a46e3b74047a7c3e497ac57a5746c9aee7099540d2457178005e2ce37698de57d08
    HEAD_REF master
)

#Build
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/baseee
    PREFER_NINJA 
)

#If DEBUG ,Baseee won't Install
if(CMAKE_BUILD_TYPE STREQUAL Release)                 
vcpkg_install_cmake()
endig()

# Add License
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/baseee/copyright)

# do something
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
SET(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")