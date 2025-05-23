unit_test_check_variable_not_equal(
    [[ z_vcpkg_make_determine_host_arch(host_arch) ]]
    host_arch ""
)

if(VCPKG_TARGET_IS_LINUX AND NOT host_arch STREQUAL "arm64")
    block(SCOPE_FOR VARIABLES)
    set(VCPKG_CROSSCOMPILING TRUE)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "aarch64-linux-gnu-gcc") ]]
        actual "--host=aarch64-linux-gnu"
    )
    set(VCPKG_CROSSCOMPILING FALSE)
    unit_test_check_variable_equal(
        [[ z_vcpkg_make_get_configure_triplets(actual COMPILER_NAME "gcc") ]]
        actual ""
    )
    endblock()
endif()

# branching as in vcpkg_make_configure
if(VCPKG_MAKE_BUILD_TRIPLET)
    set(triplets "${VCPKG_MAKE_BUILD_TRIPLET}")
else()
    z_vcpkg_make_get_configure_triplets(triplets)
endif()

if(VCPKG_HOST_IS_WINDOWS)
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--build=[^;]*-([^-;]*-[^-;]*)" output "${triplets}") ]]
        CMAKE_MATCH_1 "pc-mingw32"
    )
    if(NOT VCPKG_CROSSCOMPILING)
        # expected bad: there is --build but not --host
        unit_test_check_variable_unset(
            [[ string(REGEX MATCH "--host=([^;]*)" output "${triplets}") ]]
            CMAKE_MATCH_1
        )
    elseif(VCPKG_TARGET_IS_UWP)
        unit_test_check_variable_equal(
            [[ string(REGEX MATCH "--host=[^;]*-([^-;]*-[^-;]*)" output "${triplets}") ]]
            CMAKE_MATCH_1 "unknown-mingw32"
        )
    else()
        # maybe there is --host
    endif()
elseif(NOT VCPKG_CROSSCOMPILING)
    if(triplets)
        unit_test_check_variable_not_equal(
            [[ string(REGEX MATCH "--host=([^;]*)" output "${triplets}") ]]
            CMAKE_MATCH_1
        )
        set(autotools_host_triplet "${CMAKE_MATCH_1}")
        unit_test_check_variable_equal(
            [[ string(REGEX MATCH "--build=([^;]*)" output "${triplets}") ]]
            CMAKE_MATCH_1 "${autotools_host_triplet}"
        )
    endif()
elseif(VCPKG_TARGET_IS_ANDROID)
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--host=[^;]*-([^-;]*-(android|[^-;]*))" output "${triplets}") ]]
        CMAKE_MATCH_1 "linux-android"
    )
    # expected bad: there is --host but not --build
    unit_test_check_variable_unset(
        [[ string(REGEX MATCH "--build=([^;]*)" output "${triplets}") ]]
        CMAKE_MATCH_1
    )
elseif(VCPKG_TARGET_IS_MINGW)
    unit_test_check_variable_equal(
        [[ string(REGEX MATCH "--host=[^;]*-(mingw32|[^-;]*)" output "${triplets}") ]]
        CMAKE_MATCH_1 "mingw32"
    )
    # expected bad: there is --host but not --build
    unit_test_check_variable_unset(
        [[ string(REGEX MATCH "--build=([^;]*)" output "${triplets}") ]]
        CMAKE_MATCH_1
    )
endif()
