include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF 8b62cede3d66803ae7df5663eb52ff3f2a1f8bf5 # v4.2.2
    SHA512 ae6730d5e7c59c4eec08d72e3bd311042c57e0a23cf5c26348cc21f4e08c1a4f58721cfcfaf81ec3f19db3540d49acc2a0816f5ba34d09cfb1f853de92481327
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
