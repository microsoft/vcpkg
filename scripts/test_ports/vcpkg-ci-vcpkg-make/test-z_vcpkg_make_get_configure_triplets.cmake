z_vcpkg_make_get_configure_triplets(triplets)

# Either none or both of --host, --build
if(triplets MATCHES "--host|--build")
    unit_test_check_variable_not_equal(
        [[ string(REGEX MATCH "--host=([^;]+)" actual "${triplets}") ]]
        CMAKE_MATCH_1 ""
    )
    unit_test_check_variable_not_equal(
        [[ string(REGEX MATCH "--build=([^;]+)" actual "${triplets}") ]]
        CMAKE_MATCH_1 ""
    )
endif()

# Get the actual --build option, for use in the following tests.
block(SCOPE_FOR VARIABLES  PROPAGATE build_opt)
    if(triplets STREQUAL "")
        # Initially empty triplets are okay (= native build).
        # Force non-empty triplets via explicit --host.
        set(VCPKG_MAKE_BUILD_TRIPLET "--host=vcpkg")
        z_vcpkg_make_get_configure_triplets(triplets)
    endif()
    string(REGEX MATCH "--host=[^;]*" host_opt "${triplets};")
    unit_test_check_variable_not_equal(
        [[ # match --host ]]
        host_opt ""
    )
    string(REGEX MATCH "--build=[^;]*" build_opt "${triplets};")
    unit_test_check_variable_not_equal(
        [[ # match --build ]]
        build_opt ""
    )
endblock()

# --host precedence: VCPKG_MAKE_BUILD_TRIPLET, COMPILER_NAME, hard-coded
if(VCPKG_MAKE_BUILD_TRIPLET MATCHES "--host=([^;]*)")
    set(expected "${CMAKE_MATCH_1}")
    z_vcpkg_make_get_configure_triplets(output COMPILER_NAME "x86_64-linux-gnu-clang-12")
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--host=([^;]*)" actual "${output}") ]]
        CMAKE_MATCH_1 "${expected}"
    )
elseif(VCPKG_TARGET_IS_ANDROID)
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--host=[^;]*-([^-;]*-(android|[^-;]*))" output "${triplets}") ]]
        CMAKE_MATCH_1 "linux-android"
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "/bin/armv7a-linux-androideabi28-clang") ]]
        actual "--host=armv7a-linux-androideabi28;${build_opt}"
    )
elseif(VCPKG_TARGET_IS_MINGW)
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--host=[^;]*-(mingw32|[^-;]*)" output "${triplets}") ]]
        CMAKE_MATCH_1 "mingw32"
    )
elseif(VCPKG_TARGET_IS_LINUX)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "gcc") ]]
        actual ""
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "/bin/aarch64-linux-gnu-gcc-13") ]]
        actual "--host=aarch64-linux-gnu;${build_opt}"
    )
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "/usr/bin/x86_64-linux-gnu-clang-12") ]]
        actual "--host=x86_64-linux-gnu;${build_opt}"
    )
elseif(VCPKG_TARGET_IS_UWP)
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--host=[^;]*-([^-;]*-[^-;]*)" output "${triplets}") ]]
        CMAKE_MATCH_1 "unknown-mingw32"
    )
elseif(VCPKG_TARGET_IS_WINDOWS)
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--host=[^;]*-([^-;]*-[^-;]*)" output "${triplets}") ]]
        CMAKE_MATCH_1 "pc-mingw32"
    )
endif()

# VCPKG_MAKE_BUILD_TRIPLET robustness
block(SCOPE_FOR VARIABLES)
    set(VCPKG_MAKE_BUILD_TRIPLET "--host=HHH;--build=BBB")
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual) ]]
        actual "--host=HHH;--build=BBB"
    )
    set(VCPKG_MAKE_BUILD_TRIPLET "--build=bbb;--host=hhh")
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual) ]]
        actual "--build=bbb;--host=hhh"
    )
endblock()
