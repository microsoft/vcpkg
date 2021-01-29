vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF 8da8f0d5a434a6fb2f317022221ea0809914d4a6 # v4.2.4
    SHA512 e5cfdad793db3b3d5ff093e4120a5131000677504eed09c02817c9a49699c044a88183413ad7b09946abb0258df34fe444078c375a5bf70589345d2aa2c2283b
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DKANGARU_EXPORT=Off -DKANGARU_TEST=Off -DKANGARU_REVERSE_DESTRUCTION=On
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/kangaru)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug
)


# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/kangaru/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/kangaru/LICENSE ${CURRENT_PACKAGES_DIR}/share/kangaru/copyright)
