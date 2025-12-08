set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/gz-sim
    REF 9.0.0
    SHA512 4ac9debe27a41233c7c2116bd80f277ebe74f4ae639f06555cec4209bb7af6fe741197705fac222b4e00c8493daaf701b1eefee4ff639fdea70703bed80e0f8a
    HEAD_REF main
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/examples/standalone/light_control"
    OPTIONS
        "-DPython3_EXECUTABLE=${PYTHON3}"
)
vcpkg_cmake_build()
