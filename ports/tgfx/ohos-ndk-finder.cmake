# Helper function to read JSON file and extract apiVersion
function(find_ohos_ndk_version NDK_PATH RESULT_VAR)
    set(${RESULT_VAR} "" PARENT_SCOPE)
    
    if(NOT NDK_PATH)
        return()
    endif()
    
    set(VERSION_FILE "${NDK_PATH}/oh-uni-package.json")
    if(NOT EXISTS "${VERSION_FILE}")
        return()
    endif()
    
    file(READ "${VERSION_FILE}" FILE_CONTENT)
    
    # Parse JSON to extract apiVersion
    # CMake doesn't have native JSON parsing before 3.19, so we use regex
    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19")
        # Use native JSON parsing if available
        string(JSON API_VERSION ERROR_VARIABLE JSON_ERROR GET "${FILE_CONTENT}" "apiVersion")
        if(NOT JSON_ERROR)
            set(${RESULT_VAR} "${API_VERSION}" PARENT_SCOPE)
        endif()
    else()
        # Fallback regex parsing for older CMake versions
        string(REGEX MATCH "\"apiVersion\"[ \t]*:[ \t]*\"([^\"]+)\"" _ "${FILE_CONTENT}")
        if(CMAKE_MATCH_1)
            set(${RESULT_VAR} "${CMAKE_MATCH_1}" PARENT_SCOPE)
        endif()
    endif()
endfunction()

# Helper function to find files recursively with pattern matching
function(find_files_recursive ROOT_DIR PATTERN RESULT_VAR)
    set(${RESULT_VAR} "" PARENT_SCOPE)
    
    if(NOT EXISTS "${ROOT_DIR}")
        return()
    endif()
    
    file(GLOB_RECURSE ALL_FILES "${ROOT_DIR}/*")
    set(MATCHED_FILES "")
    
    foreach(FILE_PATH ${ALL_FILES})
        get_filename_component(FILE_NAME "${FILE_PATH}" NAME)
        if(FILE_NAME MATCHES "${PATTERN}")
            # Check if path contains "native" (equivalent to filePath.indexOf("native") >= 0)
            string(FIND "${FILE_PATH}" "native" NATIVE_POS)
            if(NATIVE_POS GREATER_EQUAL 0)
                list(APPEND MATCHED_FILES "${FILE_PATH}")
            endif()
        endif()
    endforeach()
    
    set(${RESULT_VAR} "${MATCHED_FILES}" PARENT_SCOPE)
endfunction()

# Find DevEco Studio installation path
function(find_deveco_path RESULT_VAR)
    set(${RESULT_VAR} "" PARENT_SCOPE)
    
    if(CMAKE_HOST_WIN32)
        set(PROGRAM_FILES "$ENV{PROGRAMFILES}")
        if(PROGRAM_FILES)
            set(DEVECO_PATH "${PROGRAM_FILES}/Huawei/DevEco Studio")
            if(EXISTS "${DEVECO_PATH}")
                set(${RESULT_VAR} "${DEVECO_PATH}" PARENT_SCOPE)
                return()
            endif()
        endif()
    elseif(CMAKE_HOST_APPLE)
        set(DEVECO_PATH "/Applications/DevEco-Studio.app/Contents")
        if(EXISTS "${DEVECO_PATH}")
            set(${RESULT_VAR} "${DEVECO_PATH}" PARENT_SCOPE)
            return()
        endif()
    endif()
    
    # Linux or other platforms - could be extended if needed
    # Currently returns empty string as per original JS logic
endfunction()

# Main function to find OHOS NDK
function(find_ohos_ndk RESULT_PATH_VAR RESULT_VERSION_VAR)
    set(${RESULT_PATH_VAR} "" PARENT_SCOPE)
    set(${RESULT_VERSION_VAR} "" PARENT_SCOPE)
    
    set(CMAKE_OHOS_NDK "$ENV{CMAKE_OHOS_NDK}")
    if(CMAKE_OHOS_NDK)
        find_ohos_ndk_version("${CMAKE_OHOS_NDK}" NDK_VERSION)
        if(NDK_VERSION)
            message(STATUS "Use the OHOS NDK set by parent cmake project: ${CMAKE_OHOS_NDK}")
            set(${RESULT_PATH_VAR} "${CMAKE_OHOS_NDK}" PARENT_SCOPE)
            set(${RESULT_VERSION_VAR} "${NDK_VERSION}" PARENT_SCOPE)
            return()
        endif()
    endif()
    
    find_deveco_path(DEVECO_PATH)
    if(DEVECO_PATH)
        set(SDK_PATH "${DEVECO_PATH}/sdk")
        find_files_recursive("${SDK_PATH}" "oh-uni-package\\.json" VERSION_FILE_PATHS)
        
        foreach(VERSION_FILE_PATH ${VERSION_FILE_PATHS})
            get_filename_component(NDK_PATH "${VERSION_FILE_PATH}" DIRECTORY)
            find_ohos_ndk_version("${NDK_PATH}" NDK_VERSION)
            if(NDK_VERSION)
                message(STATUS "Found OHOS NDK in DevEco Studio: ${NDK_PATH}")
                set(${RESULT_PATH_VAR} "${NDK_PATH}" PARENT_SCOPE)
                set(${RESULT_VERSION_VAR} "${NDK_VERSION}" PARENT_SCOPE)
                return()
            endif()
        endforeach()
    endif()
    
    set(OHOS_SDK "$ENV{OHOS_SDK}")
    if(OHOS_SDK)
        set(NDK_PATH "${OHOS_SDK}/native")
        find_ohos_ndk_version("${NDK_PATH}" NDK_VERSION)
        if(NDK_VERSION)
            message(STATUS "Found OHOS NDK via OHOS_SDK: ${NDK_PATH}")
            set(${RESULT_PATH_VAR} "${NDK_PATH}" PARENT_SCOPE)
            set(${RESULT_VERSION_VAR} "${NDK_VERSION}" PARENT_SCOPE)
            return()
        endif()
    endif()
    
    message(WARNING "OHOS NDK not found. Please set CMAKE_OHOS_NDK or OHOS_SDK environment variable.")
endfunction()