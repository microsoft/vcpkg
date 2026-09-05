set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH GRAPHVIZ_PATH
    REPO graphviz/graphviz
    REF 14.0.4
    SHA512 993a39a1c18d1b4d34596ee2e3e16189b7ac757bfc1feee28efd928525f83c54a1b785579e5a4b0f9c8ce8269063a3542398c592c397d338053443e8f93ca3a2
    HEAD_REF main
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_PORT_DIR}/project"
    OPTIONS
        "-DGRAPHVIZ_PATH=${GRAPHVIZ_PATH}"
)
vcpkg_cmake_build()
