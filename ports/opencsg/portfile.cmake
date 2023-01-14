vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO floriankirsch/OpenCSG
    REF "opencsg-1-4-2-release"
    SHA512 df117a1b7153a95332d236918d1547b0afe6f3ead46af2733c5feee6e25cec984b21affc41fd8320a45be9292bd3b32e21ed8bb3d08371ddd657f659b9bb932a
    HEAD_REF master
    PATCHES illegal_char.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DUNICODE=1 -D_UNICODE=1
    # OPTIONS_RELEASE -DOPTIMIZE=1
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
