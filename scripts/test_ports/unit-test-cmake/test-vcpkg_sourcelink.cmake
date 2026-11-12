block(SCOPE_FOR VARIABLES)
set(CURRENT_PACKAGES_DIR "${CURRENT_BUILDTREES_DIR}/sourcelink/packages")
set(source_path "${CURRENT_BUILDTREES_DIR}/sourcelink/source")
set(server_path "https://example.invalid/repo/ref/*")
file(MAKE_DIRECTORY "${source_path}/include/sample")

function(check_sourcelink_pair from to)
    file(READ "${CURRENT_PACKAGES_DIR}/share/sourcelink/${PORT}.json" json)
    file(TO_NATIVE_PATH "__VCPKG_INSTALLED_TRIPLET_DIR__/include/${from}" key)
    string(REPLACE "*" "${to}" expected "${server_path}")
    unit_test_check_variable_equal([[string(JSON value GET "${json}" documents "${key}")]] value "${expected}")
endfunction()

unit_test_ensure_success([[
    vcpkg_write_sourcelink_file(
        SOURCE_PATH "${source_path}" SERVER_PATH "${server_path}"
        RAW_INCLUDE_MAPPING "sample/*" "src/*" "sample.h" "api/sample.h"
    )
]])
check_sourcelink_pair("sample/*" "src/*")
check_sourcelink_pair("sample.h" "api/sample.h")

unit_test_ensure_success([[
    vcpkg_write_sourcelink_file(
        SOURCE_PATH "${source_path}" SERVER_PATH "${server_path}"
        RAW_INCLUDE_MAPPING "sample/*;src/*;sample.h;api/sample.h"
    )
]])
check_sourcelink_pair("sample/*" "src/*")
check_sourcelink_pair("sample.h" "api/sample.h")

unit_test_ensure_fatal_error([[
    vcpkg_write_sourcelink_file(
        SOURCE_PATH "${source_path}" SERVER_PATH "${server_path}"
        RAW_INCLUDE_MAPPING "sample/*" "src/*" "dangling.h"
    )
]])
unit_test_ensure_fatal_error([[
    vcpkg_write_sourcelink_file(
        SOURCE_PATH "${source_path}" SERVER_PATH "${server_path}"
        RAW_INCLUDE_MAPPING "dangling.h"
    )
]])

unit_test_ensure_success([[
    vcpkg_write_sourcelink_file(
        SOURCE_PATH "${source_path}" SERVER_PATH "${server_path}"
        RAW_SEARCH_REPO_NAME sample
    )
]])
check_sourcelink_pair("${PORT}/*" "include/sample/*")

unit_test_ensure_success([[
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}"
            "-DSCRIPTS=${SCRIPTS}"
            "-DTEST_ROOT=${CURRENT_BUILDTREES_DIR}/sourcelink/helpers"
            -P "${CMAKE_CURRENT_LIST_DIR}/sourcelink/helpers.cmake"
        WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
        LOGNAME "sourcelink-helpers"
    )
]])

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW AND NOT VCPKG_TARGET_IS_UWP AND NOT VCPKG_CROSSCOMPILING)
    foreach(mode IN ITEMS first updated empty)
        unit_test_ensure_success([[
            vcpkg_execute_required_process(
                COMMAND "${CMAKE_COMMAND}"
                    -S "${CMAKE_CURRENT_LIST_DIR}/sourcelink"
                    -B "${CURRENT_BUILDTREES_DIR}/sourcelink/consumer"
                    "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
                    "-DVCPKG_INSTALLED_DIR=${CURRENT_BUILDTREES_DIR}/sourcelink/installed tree"
                    "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
                    -DVCPKG_MANIFEST_MODE=OFF
                    -DVCPKG_APPLOCAL_DEPS=OFF
                    "-DTEST_MODE=${mode}"
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
                LOGNAME "sourcelink-${mode}"
            )
        ]])
    endforeach()
endif()
endblock()
