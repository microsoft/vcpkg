cmake_minimum_required(VERSION 3.25)
project(knncolle-test CXX)

find_package(knncolle_knncolle CONFIG REQUIRED)
find_package(knncolle_knncolle_annoy CONFIG REQUIRED)
find_package(knncolle_knncolle_hnsw CONFIG REQUIRED)
find_package(knncolle_knncolle_kmknn CONFIG REQUIRED)

add_executable(main main.cpp)

target_link_libraries(main PRIVATE
    knncolle::knncolle
    knncolle::knncolle_annoy
    knncolle::knncolle_hnsw
    knncolle::knncolle_kmknn
)
