cmake_minimum_required(VERSION 3.10)
project(cmake-js-fetch)

set(f ${CMAKE_CURRENT_BINARY_DIR}/node.cmake)

foreach(p ${CMAKE_JS_INC})
  string(REPLACE "\\" "\\\\" p ${p})
  file(APPEND ${f} "set(CMAKE_JS_INC \"${p}\")\n")
endforeach()

foreach(p ${CMAKE_JS_SRC})
  string(REPLACE "\\" "\\\\" p ${p})
  file(APPEND ${f} "set(CMAKE_JS_SRC \"${p}\")\n")
endforeach()

foreach(p ${CMAKE_JS_LIB})
  string(REPLACE "\\" "\\\\" p ${p})
  file(APPEND ${f} "set(CMAKE_JS_LIB \"${p}\")\n")
endforeach()
