include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gracicot/kangaru
    REF v4.1.2
    SHA512 44ca94da38c80aa8495bb58cc26db0591d5e1b32b52c3ff242d95598856c5e84f25d7e7184c1e15e44d9a89987856740548fb070ad393cbe51da4bb79aa216d2
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DKANGARU_EXPORT=Off -DKANGARU_TEST=Off
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/kangaru")

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/lib
	${CURRENT_PACKAGES_DIR}/debug
)


# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/kangaru/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/kangaru/LICENSE ${CURRENT_PACKAGES_DIR}/share/kangaru/copyright)
