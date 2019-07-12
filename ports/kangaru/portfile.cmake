include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF 06c7da37a4481bd5884ef1066efa4f3d74e2bda9
    SHA512 94fadc34a23871914d10f8af936885c278c5e85bd7f7c5da504c7024fb9591c016334c4c8ad39d040bb705eff0f39979d4f548894eab4cf8fb0c1b970e9f92fa
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DKANGARU_EXPORT=Off -DKANGARU_TEST=Off
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
