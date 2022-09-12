# Based on qtwebengine
find_program(NODEJS NAMES node PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/node" "bin" NO_DEFAULT_PATHS)
find_program(NODEJS NAMES node)
if(NOT NODEJS)
    message(FATAL_ERROR "node not found! Please install it via your system package manager!")
endif()

get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY)

# check if vcpkg host is windows
if(VCPKG_TARGET_IS_WINDOWS)
    set(npm_command "${NODEJS_DIR}/npm.cmd")
else()
    set(npm_command "${NODEJS_DIR}/npm")
endif()

file(REMOVE_RECURSE "${DOWNLOADS}/npm-temp")

vcpkg_execute_npm_command(
    NPM_COMMAND ${npm_command}
    COMMAND install cmake-js@7.0.0-3
    WORKING_DIRECTORY "${NODEJS_DIR}" 
)

vcpkg_execute_npm_command(
    NPM_COMMAND ${npm_command}
    COMMAND run cmake-js-fetch --scripts-prepend-node-path -- --out "${DOWNLOADS}/npm-temp"
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" 
)

include("${DOWNLOADS}/npm-temp/node.cmake")

file(COPY "${CMAKE_JS_INC}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

# Non-empty only for Windows at the current version of NodeJS
if(CMAKE_JS_SRC)
    file(COPY "${CMAKE_JS_SRC}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node")
endif()

# Handle copyright
file(INSTALL "${NODEJS_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)