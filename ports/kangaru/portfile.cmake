include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF v4.2.0
    SHA512 7ded5ee8604304b7deb91464702670e236a52c87e3b75fa57ee41eeac809654bf869ada38fea172bb835667207658807b737046089e3c0ad81059724e583da1f
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
