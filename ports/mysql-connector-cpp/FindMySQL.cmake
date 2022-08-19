find_package(libmysql REQUIRED)

set(MYSQL_INCLUDE_DIR "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/include/mysql")

if(NOT EXISTS "${MYSQL_INCLUDE_DIR}/mysql.h")
  message(FATAL_ERROR "MYSQL_INCLUDE_DIR given, but no \"mysql.h\" in \"${MYSQL_INCLUDE_DIR}\"")
endif()

# Write the C source file that will include the MySQL headers
set(GETMYSQLVERSION_SOURCEFILE "${CMAKE_CURRENT_BINARY_DIR}/getmysqlversion.c")
file(WRITE "${GETMYSQLVERSION_SOURCEFILE}"
  "#include <mysql.h>\n"
  "#include <stdio.h>\n"
  "int main() {\n"
  "  printf(\"%s\", MYSQL_SERVER_VERSION);\n"
  "}\n"
)

# Compile and run the created executable, store output in MYSQL_VERSION
try_run(_run_result _compile_result
  "${CMAKE_BINARY_DIR}"
  "${GETMYSQLVERSION_SOURCEFILE}"
  CMAKE_FLAGS "-DINCLUDE_DIRECTORIES:STRING=${MYSQL_INCLUDE_DIR}"
  RUN_OUTPUT_VARIABLE MYSQL_VERSION
)

if(NOT MYSQL_VERSION)
  message(FATAL_ERROR "Could not determine the MySQL Server version")
endif()

# Clean up so only numeric, in case of "-alpha" or similar
string(REGEX MATCHALL "([0-9]+.[0-9]+.[0-9]+)" MYSQL_VERSION "${MYSQL_VERSION}")

# To create a fully numeric version, first normalize so N.NN.NN
string(REGEX REPLACE "[.]([0-9])[.]" ".0\\1." MYSQL_VERSION_ID "${MYSQL_VERSION}")
string(REGEX REPLACE "[.]([0-9])$" ".0\\1" MYSQL_VERSION_ID "${MYSQL_VERSION_ID}")

# Finally remove the dot
string(REGEX REPLACE "[.]" "" MYSQL_VERSION_ID "${MYSQL_VERSION_ID}")
set(MYSQL_NUM_VERSION ${MYSQL_VERSION_ID})

include_directories("${MYSQL_INCLUDE_DIR}")
