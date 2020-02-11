include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/jbig2dec
    REF d5db179ea91b1da54df81adb8d5d6d2573117b6a # 0.17
    SHA512 1d12da6f666d2a87c6cd7dc4fc7cd7a21b4c15cd299027d134885cfe0aaab0e5908a3eb3249a70f2ccba763c7b0a3accb334efdb0bbe5adc2e644125c602fa1c
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/jbig2dec RENAME copyright)
