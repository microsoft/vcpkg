if(NOT VCPKG_TARGET_IS_WINDOWS)
   list(APPEND PATCHES "prevent-cmake-failing-with-variable-notfound.patch")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/ki18n
    REF v5.81.0
    SHA512 8e14c429671a51b9b231f2a965f2368b019592a29a04a9e192da25a8a963042fe7478323508c097f73e2c328fd4742f8808fe68ea439e00e6667414d7f75be3e
    PATCHES ${PATCHES}
)

if(CMAKE_HOST_WIN32)
    vcpkg_acquire_msys(MSYS_ROOT NO_DEFAULT_PACKAGES DIRECT_PACKAGES
        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gettext-0.19.8.1-9-any.pkg.tar.zst"
        c632877544183def8b19659421c5511b87f8339596e1606bd47608277a0bf427d370aba1732915c2832c91f6d525261623401f145b951ff3015f79ac54179c19
        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libiconv-1.16-1-any.pkg.tar.xz"
        ba236e1efc990cb91d459f938be6ca6fc2211be95e888d73f8de301bce55d586f9d2b6be55dacb975ec1afa7952b510906284eff70210238919e341dffbdbeb8
        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gcc-libs-10.2.0-1-any.pkg.tar.zst"
        113d8b3b155ea537be8b99688d454f781d70c67c810c2643bc02b83b332d99bfbf3a7fcada6b927fda67ef02cf968d4fdf930466c5909c4338bda64f1f3f483e
        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-libwinpthread-git-8.0.0.5906.c9a21571-1-any.pkg.tar.zst"
        2c3d9e6b2eee6a4c16fd69ddfadb6e2dc7f31156627d85845c523ac85e5c585d4cfa978659b1fe2ec823d44ef57bc2b92a6127618ff1a8d7505458b794f3f01c
        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpc-1.1.0-1-any.pkg.tar.xz"
        d236b815ec3cf569d24d96a386eca9f69a2b1e8af18e96c3f1e5a4d68a3598d32768c7fb3c92207ecffe531259822c1a421350949f2ffabd8ee813654f1af864
        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-mpfr-4.1.0-2-any.pkg.tar.zst"
        caac5cb73395082b479597a73c7398bf83009dbc0051755ef15157dc34996e156d4ed7881ef703f9e92861cfcad000888c4c32e4bf38b2596c415a19aafcf893
        "https://repo.msys2.org/mingw/i686/mingw-w64-i686-gmp-6.2.0-1-any.pkg.tar.xz"
        37747f3f373ebff1a493f5dec099f8cd6d5abdc2254d9cd68a103ad7ba44a81a9a97ccaba76eaee427b4d67b2becb655ee2c379c2e563c8051b6708431e3c588
    )
    set(GETTEXT_PATH ${MSYS_ROOT}/mingw32/bin)
    vcpkg_add_to_path(${GETTEXT_PATH})
endif()

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_HTML_DOCS=OFF
        -DBUILD_MAN_DOCS=OFF
        -DBUILD_QTHELP_DOCS=OFF
        -DBUILD_TESTING=OFF
        -DKDE_INSTALL_PLUGINDIR=plugins
        -DPYTHON_EXECUTABLE=${PYTHON3}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5I18n)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)

file(INSTALL ${SOURCE_PATH}/LICENSES/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
