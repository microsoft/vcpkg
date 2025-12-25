vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Samsung/rlottie
        REF 36ddb42d78d1b13c1b1d7e1699aef8a9f339ab6f
        SHA512 ac7673afc60ca3c35a3d144c01ee611a2b01b052155ce225ad27b1f5d21dae9fa6cf02b5761a6ee8faade639b0aba2862938e2b26b8e3b43451974e7b0adef41
        PATCHES
            0001-cmakelists-vcpkg-and-rapidjson-support.patch
            0002-lottieparser-fix-rapidjson-include.patch
            0003-vector-cmakelists-remove-pixman.patch
            0004-vector-vdrawhelper-remove-pixman.patch
            0005-lottieparser-windows-path-parsing.patch
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DLIB_INSTALL_DIR=lib
            -DLOTTIE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/rlottie")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/AUTHORS")
