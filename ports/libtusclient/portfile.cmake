vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Cadons/libtusclient
        REF 1.0.1
        SHA512 dbe0aeb64eee28aa8fe3f0acedcbfe09d3424ba79ed25168a8919c1ff43b262ecac0410fb6be2a23fec5769bdb6f0b2f44d996545bd2ab1d0f129b234e5549c7
        HEAD_REF main
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DBUILD_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

