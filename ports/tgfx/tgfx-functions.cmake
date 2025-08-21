function(parse_and_declare_deps_externals SOURCE_PATH)
    if(NOT EXISTS "${SOURCE_PATH}/DEPS")
        message(FATAL_ERROR "DEPS file not found at ${SOURCE_PATH}/DEPS")
    endif()

    file(READ "${SOURCE_PATH}/DEPS" DEPS_CONTENT)

    if(CMAKE_VERSION VERSION_LESS "3.19")
        message(FATAL_ERROR "CMake 3.19+ is required for JSON parsing")
    endif()

    string(JSON VARS_SECTION GET "${DEPS_CONTENT}" "vars")
    string(JSON PAG_GROUP GET "${VARS_SECTION}" "PAG_GROUP")

    string(JSON REPOS_SECTION GET "${DEPS_CONTENT}" "repos")
    string(JSON COMMON_REPOS GET "${REPOS_SECTION}" "common")
    string(JSON REPOS_COUNT LENGTH "${COMMON_REPOS}")

    message(STATUS "Found ${REPOS_COUNT} dependencies in DEPS file")

    set_property(GLOBAL PROPERTY TGFX_EXTERNALS "")

    math(EXPR REPOS_LAST_INDEX "${REPOS_COUNT} - 1")
    foreach(INDEX RANGE 0 ${REPOS_LAST_INDEX})
        string(JSON REPO_INFO GET "${COMMON_REPOS}" ${INDEX})
        string(JSON REPO_URL GET "${REPO_INFO}" "url")
        string(JSON REPO_COMMIT GET "${REPO_INFO}" "commit")
        string(JSON REPO_DIR GET "${REPO_INFO}" "dir")
        string(JSON VCPKG_MANAGED ERROR_VARIABLE VCPKG_ERROR GET "${REPO_INFO}" "vcpkg")
        
        if(VCPKG_ERROR)
            set(VCPKG_MANAGED FALSE)
        endif()

        string(REPLACE "\${PAG_GROUP}" "${PAG_GROUP}" REPO_URL "${REPO_URL}")

        get_filename_component(DEP_NAME "${REPO_DIR}" NAME)

        if(VCPKG_MANAGED)
            message(STATUS "Skipping ${DEP_NAME} - managed by vcpkg")
        else()
            message(STATUS "Declaring external dependency: ${DEP_NAME}")
            declare_tgfx_external_from_git(
                ${DEP_NAME}
                URL "${REPO_URL}"
                REF "${REPO_COMMIT}"
                DIR "${REPO_DIR}"
            )
        endif()
    endforeach()
endfunction()

function(declare_tgfx_external_from_git NAME)
    cmake_parse_arguments(PARSE_ARGV 1 arg "" "URL;REF;DIR" "")

    if(NOT arg_URL OR NOT arg_REF OR NOT arg_DIR)
        message(FATAL_ERROR "declare_tgfx_external_from_git requires URL, REF, and DIR arguments")
    endif()

    set_property(GLOBAL PROPERTY "TGFX_EXTERNAL_${NAME}_URL" "${arg_URL}")
    set_property(GLOBAL PROPERTY "TGFX_EXTERNAL_${NAME}_REF" "${arg_REF}")
    set_property(GLOBAL PROPERTY "TGFX_EXTERNAL_${NAME}_DIR" "${arg_DIR}")

    get_property(EXTERNALS GLOBAL PROPERTY TGFX_EXTERNALS)
    list(APPEND EXTERNALS "${NAME}")
    set_property(GLOBAL PROPERTY TGFX_EXTERNALS "${EXTERNALS}")
endfunction()

function(get_tgfx_external_from_git SOURCE_PATH)
    get_property(EXTERNALS GLOBAL PROPERTY TGFX_EXTERNALS)

    if(NOT EXTERNALS)
        message(STATUS "No external dependencies to fetch")
        return()
    endif()

    file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party")

    foreach(EXTERNAL ${EXTERNALS})
        get_property(URL GLOBAL PROPERTY "TGFX_EXTERNAL_${EXTERNAL}_URL")
        get_property(REF GLOBAL PROPERTY "TGFX_EXTERNAL_${EXTERNAL}_REF")
        get_property(DIR GLOBAL PROPERTY "TGFX_EXTERNAL_${EXTERNAL}_DIR")

        message(STATUS "Fetching external dependency: ${EXTERNAL} from ${URL}")

        vcpkg_from_git(
            OUT_SOURCE_PATH DEP_SOURCE_PATH
            URL "${URL}"
            REF "${REF}"
        )

        get_filename_component(TARGET_DIR "${SOURCE_PATH}/${DIR}" DIRECTORY)
        file(MAKE_DIRECTORY "${TARGET_DIR}")

        message(STATUS "Copying ${EXTERNAL} to ${SOURCE_PATH}/${DIR}")
        file(COPY "${DEP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/${DIR}")
    endforeach()

    message(STATUS "Successfully fetched all external dependencies")
endfunction()