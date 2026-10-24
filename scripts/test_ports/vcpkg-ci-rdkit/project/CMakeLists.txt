cmake_minimum_required(VERSION 3.20)
project(vcpkg-ci-rdkit LANGUAGES CXX)

find_package(rdkit CONFIG REQUIRED)

add_executable(rdkit-cairo-consumer main.cpp)
target_compile_features(rdkit-cairo-consumer PRIVATE cxx_std_20)
target_link_libraries(rdkit-cairo-consumer PRIVATE
    RDKit::MolDraw2D
    RDKit::SmilesParse
)

install(TARGETS rdkit-cairo-consumer
    RUNTIME DESTINATION "bin/${PROJECT_NAME}"
)
