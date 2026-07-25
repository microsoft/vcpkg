cmake_minimum_required(VERSION 4.3.3)

project(vcpkg-cpp-module-consumer VERSION 1.0.0)

find_package(provider REQUIRED)

add_executable(consumer)
target_compile_features(consumer PRIVATE cxx_std_20)
target_link_libraries(consumer PRIVATE provider::provider)

target_sources(consumer
  PRIVATE
    src/consumer.cpp
)

install(TARGETS consumer
  RUNTIME DESTINATION bin
)
