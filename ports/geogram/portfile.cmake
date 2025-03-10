vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BrunoLevy/geogram
    REF "v${VERSION}"
    SHA512 19cf5720496172a144b2c5725a0a9763fde730ee14af75d92598973ff84106619e564d34746fd7b3da7d56f0cf52654fa656e3228fb32c0897f3aba178421f28
    PATCHES
        fix-vcpkg-install.patch
)

#third_party: amgcl
vcpkg_from_github(
    OUT_SOURCE_PATH AMGCL_SOURCE_PATH
    REPO ddemidov/amgcl
    REF a705f0822a332e215c41bccbeb6a7d92e90c49f2
    SHA512 09dda0eb318ee4cd74af9ea67d9fcdce8a4399ab08b08cd72e2c7de953ad584204402b932c2a3222b7c74b25934267230bbc333a377e25f87ad045087ace2000
)

#third_party: libMeshb
vcpkg_from_github(
    OUT_SOURCE_PATH LIBMESHB_SOURCE_PATH
    REPO LoicMarechal/libMeshb
    REF e3678731ef14497c720ee7017a14450eba2602d2
    SHA512 5c8f25805ce02cb48600914893f24ecd2dcbb8226692d47089605ff99db8785781407ec9152e29b0c3bc44d16f6d893cd171e5337c3cb1861468da05471872b6
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
    IGNORE_UNCHANGED
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/devkit/license.dox")

vcpkg_fixup_pkgconfig()
