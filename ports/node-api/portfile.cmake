# Based on qtwebengine
find_program(NODEJS NAMES node PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/node" "bin" NO_DEFAULT_PATHS)
find_program(NODEJS NAMES node)
if(NOT NODEJS)
    message(FATAL_ERROR "node not found! Please install it via your system package manager!")
endif()

get_filename_component(NODEJS_DIR "${NODEJS}" DIRECTORY)

# check if vcpkg host is windows
if(VCPKG_HOST_IS_WINDOWS)
    set(npm_command "${NODEJS_DIR}/npm.cmd")
else()
    set(npm_command "${NODEJS_DIR}/npm")
endif()

file(REMOVE_RECURSE "${DOWNLOADS}/tmp-cmakejs-output")
file(REMOVE_RECURSE "${DOWNLOADS}/tmp-cmakejs-home")
file(MAKE_DIRECTORY "${DOWNLOADS}/tmp-cmakejs-output")
file(MAKE_DIRECTORY "${DOWNLOADS}/tmp-cmakejs-home")

vcpkg_execute_npm_command(
    NPM_COMMAND ${npm_command}
    COMMAND install cmake-js@7.0.0-3
    WORKING_DIRECTORY "${NODEJS_DIR}"
)

# Precent pollution of user home directory
file(READ "${NODEJS_DIR}/node_modules/cmake-js/lib/environment.js" environment_js)
string(REPLACE "process.env[(os.platform() === \"win32\") ? \"USERPROFILE\" : \"HOME\"]" "\"${DOWNLOADS}/tmp-cmakejs-home\"" environment_js "${environment_js}")
file(WRITE "${NODEJS_DIR}/node_modules/cmake-js/lib/environment.js" "${environment_js}")

vcpkg_execute_npm_command(
    NPM_COMMAND ${npm_command}
    COMMAND run cmake-js-fetch --scripts-prepend-node-path -- --out "${DOWNLOADS}/tmp-cmakejs-output"
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" 
)

include("${DOWNLOADS}/tmp-cmakejs-output/node.cmake")

file(COPY "${CMAKE_JS_INC}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

# Non-empty only for Windows at the current version of NodeJS
if(CMAKE_JS_SRC)
    file(COPY "${CMAKE_JS_SRC}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/node")
endif()

# Handle copyright
file(INSTALL "${NODEJS_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# vcpkg remove doesn't remove cmake-js, so we need to remove it manually right now
file(GLOB cmakejs_files "${NODEJS_DIR}/cmake-js*")
file(REMOVE ${cmakejs_files})
file(REMOVE_RECURSE "${NODEJS_DIR}/node_modules/cmake-js")