vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO plplot/plplot
    REF "${VERSION}%20Source"
    FILENAME "plplot-${VERSION}.tar.gz"
    SHA512 54533245569b724a7ef90392cc6e9ae65873e6cbab923df0f841c8b43def5e4307690894c7681802209bd3c8df97f54285310a706428f79b3340cce3207087c8
    PATCHES
        cmake-config.diff
        fix-pc-absolute.patch
        install-interface-include-directories.patch
        pkg_config_link_flags.diff
        pkgconfig-template.diff
        subdirs.patch
        use-math-h-nan.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        wxwidgets PLD_wxwidgets
        wxwidgets ENABLE_wxwidgets
        x11       PLD_xwin
        x11       CMAKE_REQUIRE_FIND_PACKAGE_X11
    INVERTED_FEATURES
        x11       CMAKE_DISABLE_FIND_PACKAGE_X11
)

if(VCPKG_CROSSCOMPILING)
    list(APPEND FEATURE_OPTIONS "-DCMAKE_NATIVE_BINARY_DIR=${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
    # Necessary to skip a try_run which isn't used anyways due to PL_HAVE_QHULL=OFF
    list(APPEND FEATURE_OPTIONS "-DNaNAwareCCompiler=ON")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11
        -DDEFAULT_NO_BINDINGS=ON
        -DDEFAULT_NO_QT_DEVICES=ON
        -DENABLE_cxx=ON
        -DENABLE_DYNDRIVERS=OFF
        -DENABLE_qt=OFF
        -DENABLE_tk=OFF
        -DHAVE_SHAPELIB=OFF
        -DPL_DOUBLE=ON
        -DPL_HAVE_QHULL=OFF
        -DPLD_aqt=OFF   # needs aquaterm framework
        -DPLD_pdf=OFF   # needs haru
        -DPLD_psttf=OFF # needs lasi (in addition to pango)
        -DPLD_psttfc=OFF # needs lasi (in addition to pango)
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_Perl=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_Freetype=ON
    OPTIONS_DEBUG
        "-DDATA_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/data"
        "-DDOC_DIR=${CURRENT_PACKAGES_DIR}/debug/share/${PORT}/doc"
    OPTIONS_RELEASE
        "-DDATA_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}/data"
        "-DDOC_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}/doc"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/plplot)
vcpkg_fixup_pkgconfig()

if("wxwidgets" IN_LIST FEATURES)
    file(GLOB pkg_files "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
    foreach(pkg_file IN LISTS pkg_files)
        vcpkg_replace_string("${pkg_file}" [[${prefix}/lib/mswu]] [[${prefix}/lib/mswud]] IGNORE_UNCHANGED)
    endforeach()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(NOT VCPKG_CROSSCOMPILING)
    function(copy_tool name subdir cmake_name)
        vcpkg_copy_tools(
            TOOL_NAMES "${name}"
            SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${subdir}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/${subdir}"
        )
        configure_file(
            "${CURRENT_PORT_DIR}/host-tool.cmake"
            "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}/${subdir}/${cmake_name}"
            @ONLY
        )
    endfunction()
    copy_tool(plhershey-unicode-gen "include" "ImportExecutables.cmake")
    copy_tool(tai-utc-gen "lib/qsastime" "tai-utc-gen.cmake")
    copy_tool(deltaT-gen "lib/qsastime" "deltaT-gen.cmake")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/Copyright"
        "${SOURCE_PATH}/COPYING.LIB"
)
