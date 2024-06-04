vcpkg_download_distfile(FIX_IMPLICIT_INT_PATCH
    URLS https://github.com/BrunoLevy/geogram/commit/382da2d2f0d39bf8df2f65051c338e7e827e31db.patch?full_index=1
    FILENAME geogram-implicit-ini-382da2d2f0d39bf8df2f65051c338e7e827e31db.patch
    SHA512 1a85195b76cd7140fe890893bf1f57a1f9c30dbc2865bab28b7eda9d97b9bab5be7cbc638b24d8da489aee1e25e0e7289655ade13893bdc225d1b332f1d845a0
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BrunoLevy/geogram
    REF "v${VERSION}"
    SHA512 ae3d95be1c5061ace92921b3fcfb0027d23c595b131b0d31f1788adbe0d8f92367bef71736d6c936504bd37eba5fcdae658369f03734e233bf3eab14bca6f9e5
    PATCHES
        fix-vcpkg-install.patch
        "${FIX_IMPLICIT_INT_PATCH}"
)

#third_party: amgcl
vcpkg_from_github(
    OUT_SOURCE_PATH AMGCL_SOURCE_PATH
    REPO ddemidov/amgcl
    REF 8083b23fbe69c43cee0d4bc17e4334572e292c93
    SHA512 1b29871ace68c53b46711012921261929f8bd612f93b47d2c59523cd3d68366956fe1c9ec81a94b3aaab63357001799c9e34af79376b940fa6b7a53cdf136897
)

#third_party: libMeshb
vcpkg_from_github(
    OUT_SOURCE_PATH LIBMESHB_SOURCE_PATH
    REPO LoicMarechal/libMeshb
    REF b4a91513317119ff71a1186906a052da0e535913
    SHA512 bff30a233c2746a454d552be66f5654bf4af995d6f1eb00a4d21ed10c86234a5be4d6f31282645858e0a829b10fd98cad7188c69be65cdabbd18478fc26bad1f
)

#third_party: rply
vcpkg_from_github(
    OUT_SOURCE_PATH RPLY_SOURCE_PATH
    REPO diegonehab/rply
    REF 4296cc91b5c8c26d4e7d7aac0cee2b194ffc5800
    SHA512 b236279d3f0e6e1062703555415236183da31a9e40c49d478954586725f8dc6c0582aef0db7b605cb7967c3bd4a96d2fe8e6601cc56b8a1d53129a25efa7d1f2
)

file(REMOVE_RECURSE "${SOURCE_PATH}/src/lib/geogram/third_party/amgcl"
    "${SOURCE_PATH}/src/lib/geogram/third_party/libMeshb"
	"${SOURCE_PATH}/src/lib/geogram/third_party/rply")
file(RENAME "${AMGCL_SOURCE_PATH}" "${SOURCE_PATH}/src/lib/geogram/third_party/amgcl")
file(RENAME "${LIBMESHB_SOURCE_PATH}" "${SOURCE_PATH}/src/lib/geogram/third_party/libMeshb")
file(RENAME "${RPLY_SOURCE_PATH}" "${SOURCE_PATH}/src/lib/geogram/third_party/rply")

file(COPY "${CURRENT_PORT_DIR}/Config.cmake.in" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "graphics" GEOGRAM_WITH_GRAPHICS
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(VORPALINE_BUILD_DYNAMIC FALSE)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(VORPALINE_PLATFORM Win-vs-generic)
    endif()
    if (VCPKG_CRT_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
        message("geogram on Windows with CRT dynamic linkage only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Win-vs-dynamic-generic)
    endif()
    if (VCPKG_TARGET_IS_LINUX)
        message("geogram on Linux only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Linux64-gcc-dynamic )
    endif()
    if (VCPKG_TARGET_IS_OSX)
        message("geogram on Darwin only supports dynamic library linkage. Building dynamic.")
        set(VCPKG_LIBRARY_LINKAGE dynamic)
        set(VORPALINE_PLATFORM Darwin-clang-dynamic)
    endif()
else()
    set(VORPALINE_BUILD_DYNAMIC TRUE)
    if (VCPKG_TARGET_IS_WINDOWS)
        set(VORPALINE_PLATFORM Win-vs-generic)
    endif()
    if (VCPKG_TARGET_IS_LINUX)
        set(VORPALINE_PLATFORM Linux64-gcc-dynamic )
    endif()
    if (VCPKG_TARGET_IS_OSX)
        set(VORPALINE_PLATFORM Darwin-clang-dynamic)
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    # Geogram cannot be built with ninja because it embeds $(Configuration) in some of the generated paths. These require MSBuild in order to be evaluated.
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DVORPALINE_BUILD_DYNAMIC=${VORPALINE_BUILD_DYNAMIC}
        -DGEOGRAM_LIB_ONLY=ON
        -DGEOGRAM_USE_SYSTEM_GLFW3=ON
        -DVORPALINE_PLATFORM=${VORPALINE_PLATFORM}
        -DGEOGRAM_WITH_VORPALINE=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove all empty directories. 
function(auto_clean dir) 
     file(GLOB entries "${dir}/*") 
     file(GLOB files LIST_DIRECTORIES false "${dir}/*") 
     foreach(entry IN LISTS entries) 
         if(entry IN_LIST files) 
             continue() 
         endif() 
         file(GLOB_RECURSE children "${entry}/*") 
         if(children) 
             auto_clean("${entry}") 
         else() 
             file(REMOVE_RECURSE "${entry}") 
         endif() 
     endforeach() 
endfunction()
auto_clean("${CURRENT_PACKAGES_DIR}/include")

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/share/geogram/GeogramTargets.cmake"
    [[INTERFACE_INCLUDE_DIRECTORIES "/src/lib;${_IMPORT_PREFIX}/include"]]
    [[INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"]]
    )

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/devkit/license.dox")

vcpkg_fixup_pkgconfig()
