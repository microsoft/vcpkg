PROJECT(PackageTest)
cmake_minimum_required(VERSION 2.8.12)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

MESSAGE("LIBRARIES TO LINK: ${CONAN_LIBS}")

ADD_EXECUTABLE(test_exe ${TEST_FILENAME})
TARGET_LINK_LIBRARIES(test_exe ${CONAN_LIBS})
