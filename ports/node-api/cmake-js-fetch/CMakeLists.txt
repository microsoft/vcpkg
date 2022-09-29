cmake_minimum_required(VERSION 3.10)
project(cmake-js-fetch)

set(output_cmake_file ${CMAKE_CURRENT_BINARY_DIR}/node.cmake)

foreach(path ${CMAKE_JS_INC})
  string(REPLACE "\\" "\\\\" path ${path})
  file(APPEND ${output_cmake_file} "set(CMAKE_JS_INC \"${path}\")\n")
endforeach()

foreach(path ${CMAKE_JS_SRC})
  string(REPLACE "\\" "\\\\" path ${path})
  file(APPEND ${output_cmake_file} "set(CMAKE_JS_SRC \"${path}\")\n")
endforeach()

foreach(path ${CMAKE_JS_LIB})
  string(REPLACE "\\" "\\\\" path ${path})
  file(APPEND ${output_cmake_file} "set(CMAKE_JS_LIB \"${path}\")\n")
endforeach()
