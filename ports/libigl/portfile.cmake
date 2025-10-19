if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libigl/libigl
    REF  "v${VERSION}"
    SHA512 7c6ae5b94020a01df5d6d0a358592293595d8d8bf04bf42e6acc09bcd6ed012071069373a71ed6f24ce878aa79447dd189b42bc8a3a70819ef05dccc60a2cf68
    HEAD_REF master
    PATCHES
        dependencies.patch
        imgui-impl.diff
        install-extra-targets.patch
)
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/recipes")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cgal            LIBIGL_COPYLEFT_CGAL
        copyleft        LIBIGL_COPYLEFT_CORE
        embree          LIBIGL_EMBREE
        glfw            LIBIGL_GLFW
        imgui           LIBIGL_IMGUI
        opengl          LIBIGL_OPENGL
        xml             LIBIGL_XML
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_POLICY_DEFAULT_CMP0167=NEW # boost used by cgal
        -DHUNTER_ENABLED=OFF
        -DLIBIGL_BUILD_TESTS=OFF
        -DLIBIGL_BUILD_TUTORIALS=OFF
        -DLIBIGL_INSTALL=ON
        # This option enables building an actual binary library.
        # It still respects BUILD_SHARED_LIBS.
        # Missing symbols - i.e. explicit template instantiations -
        # must be added to the implementation files (and upstreamed).
        -DLIBIGL_USE_STATIC_LIBRARY=ON
        # Permissive modules
        -DLIBIGL_PREDICATES=OFF
        -DLIBIGL_SPECTRA=OFF
        # Copyleft modules
        -DLIBIGL_COPYLEFT_COMISO=OFF
        -DLIBIGL_COPYLEFT_TETGEN=OFF
        # Restricted modules
        -DLIBIGL_RESTRICTED_MATLAB=OFF
        -DLIBIGL_RESTRICTED_MOSEK=OFF
        -DLIBIGL_RESTRICTED_TRIANGLE=OFF
    OPTIONS_DEBUG
        -DCGAL_DO_NOT_WARN_ABOUT_CMAKE_BUILD_TYPE=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/igl)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(comment "")
set(licenses "${SOURCE_PATH}/LICENSE.MPL2")
if(LIBIGL_COPYLEFT_CORE)
    string(APPEND comment "GPL terms apply to the targets in the \"igl_copyleft::\" namespace.\n")
    list(APPEND licenses "${SOURCE_PATH}/LICENSE.GPL")
endif()
vcpkg_install_copyright(FILE_LIST ${licenses} COMMENT "${comment}")
