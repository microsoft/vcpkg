include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF b9532b738ad7f17569dfcaae74eb53d3c2959394
    SHA512 e75a40036b69d9066c128c396ea19a53079525e47d4661eb6465f07dbaebc2357b32a5806d9cf739fb1b8b132e29b9aefd351e15e6fd883213e5a15cbe55e971
    HEAD_REF master
    PATCHES
        cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/GNU_LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libics)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libics/GNU_LICENSE ${CURRENT_PACKAGES_DIR}/share/libics/copyright)