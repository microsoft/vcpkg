cmake_minimum_required(VERSION 3.20)
project(BacktestingEngine VERSION 1.0.1 LANGUAGES CXX)
enable_testing()

function(be_target_compile_options name)
    target_compile_options(${name} PRIVATE
        $<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang,AppleClang>:-Wall;-Wextra;-O3;-fPIC>
        $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/W4;/O2>
    )
endfunction()

# Set C++20 standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Use dynamic libraries for deployment to avoid complex dependency issues
# Static linking causes too many missing dependency issues with curl
set(CMAKE_FIND_LIBRARY_SUFFIXES .so .dylib ${CMAKE_FIND_LIBRARY_SUFFIXES})

# Find required packages
find_package(Eigen3 REQUIRED)

# Set Homebrew paths for macOS (skip when building under vcpkg)
if(APPLE AND NOT DEFINED VCPKG_TARGET_TRIPLET)
    set(HOMEBREW_PREFIX "/opt/homebrew")
    set(CMAKE_PREFIX_PATH "${HOMEBREW_PREFIX}" ${CMAKE_PREFIX_PATH})
    set(CMAKE_LIBRARY_PATH "${HOMEBREW_PREFIX}/lib" ${CMAKE_LIBRARY_PATH})
    set(CMAKE_INCLUDE_PATH "${HOMEBREW_PREFIX}/include" ${CMAKE_INCLUDE_PATH})
    message(STATUS "Using Homebrew prefix: ${HOMEBREW_PREFIX}")
endif()

# Try to find spdlog with dynamic linking preference
find_package(spdlog REQUIRED CONFIG)
if(spdlog_FOUND)
    message(STATUS "Found spdlog: ${spdlog_DIR}")
else()
    # Fallback: try to find spdlog as a regular package
    find_package(spdlog REQUIRED)
endif()

# Find dependencies via CMake packages (vcpkg/Windows friendly)
find_package(CURL REQUIRED)
find_package(yaml-cpp CONFIG REQUIRED)
find_package(Threads REQUIRED)

# Find nlohmann/json
find_package(nlohmann_json REQUIRED CONFIG)

# Optional TA-Lib (not a vcpkg dependency; vcpkg builds pass -DBACKTESTINGENGINE_ENABLE_TALIB=OFF)
option(BACKTESTINGENGINE_ENABLE_TALIB "Find and link optional TA-Lib" ON)
if(BACKTESTINGENGINE_ENABLE_TALIB)
    # Find TA-Lib with better detection
    find_library(TALIB_LIBRARY NAMES ta_lib ta_lib_csr ta_common ta_abstract)
    find_path(TALIB_INCLUDE_DIR ta_libc.h
        PATHS
        /usr/include
        /usr/local/include
        /opt/local/include
        /sw/include
    )

    # If TA-Lib is not found, try to find it in standard locations
    if(NOT TALIB_LIBRARY)
        find_library(TALIB_LIBRARY NAMES ta_lib PATHS /usr/lib /usr/local/lib /opt/local/lib /sw/lib)
    endif()

    if(NOT TALIB_INCLUDE_DIR)
        find_path(TALIB_INCLUDE_DIR ta_libc.h PATHS /usr/include /usr/local/include /opt/local/include /sw/include)
    endif()

    # Check if TA-Lib is available
    if(TALIB_LIBRARY AND TALIB_INCLUDE_DIR)
        message(STATUS "TA-Lib found: ${TALIB_LIBRARY}")
        message(STATUS "TA-Lib include dir: ${TALIB_INCLUDE_DIR}")
        set(HAS_TALIB TRUE)
    else()
        message(WARNING "TA-Lib not found. Some technical indicators may not be available.")
        message(WARNING "TALIB_LIBRARY: ${TALIB_LIBRARY}")
        message(WARNING "TALIB_INCLUDE_DIR: ${TALIB_INCLUDE_DIR}")
        set(HAS_TALIB FALSE)
    endif()
else()
    message(STATUS "TA-Lib disabled (BACKTESTINGENGINE_ENABLE_TALIB=OFF)")
    set(HAS_TALIB FALSE)
endif()

# Library source files
set(CORE_SOURCES
    src/context/regime_classifier.cpp
    src/engine/backtest_engine.cpp
    src/strategy/strategy.cpp
    src/strategy/strategy_factory.cpp
    src/strategy/moving_average_strategy.cpp
    src/strategy/rsi_strategy.cpp
    src/strategy/macd_strategy.cpp
    src/strategy/bollinger_bands_strategy.cpp
    src/strategy/multi_leg_strategy.cpp
    src/strategy/advanced_strategies.cpp
    src/strategy/natural_language_parser.cpp
    src/strategy/code_generator.cpp
    src/data/data_handler_factory.cpp
    src/data/csv_data_handler.cpp
    src/data/api_data_handler.cpp
    src/data/alpha_vantage_handler.cpp
    src/data/yfinance_handler.cpp
    src/data/iex_handler.cpp
    src/data/polygon_handler.cpp
    src/data/data_source_router.cpp
    src/data/data_validator.cpp
    src/data/stock_symbols.cpp
    src/data/technical_indicators.cpp
    src/data/symbol_cache.cpp
    src/portfolio/portfolio_manager.cpp
    src/portfolio/multi_asset_portfolio.cpp
    src/execution/execution_handler.cpp
    src/risk/risk_manager.cpp
    src/risk/advanced_risk_manager.cpp
    src/performance/performance_analyzer.cpp
)

# C API wrapper (optional but built by default for easier bindings)
list(APPEND CORE_SOURCES
    src/c_api/backtest_c.cpp
)

# CLI sources (kept out of the shared library target)
set(CLI_SOURCES
    src/cli/cli.cpp
)

# Header files
file(GLOB_RECURSE HEADERS "include/*.h")

# Shared library target (requested)
add_library(backtesting_engine_shared SHARED
    ${CORE_SOURCES}
)

add_library(BacktestingEngine::backtesting_engine_shared ALIAS backtesting_engine_shared)

target_include_directories(backtesting_engine_shared
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_link_libraries(backtesting_engine_shared
    PUBLIC
        Eigen3::Eigen
        spdlog::spdlog
        nlohmann_json::nlohmann_json
    PRIVATE
        CURL::libcurl
        yaml-cpp::yaml-cpp
        Threads::Threads
)

if(HAS_TALIB)
    target_link_libraries(backtesting_engine_shared PRIVATE ${TALIB_LIBRARY})
    target_compile_definitions(backtesting_engine_shared PRIVATE HAS_TALIB)
    target_include_directories(backtesting_engine_shared PRIVATE ${TALIB_INCLUDE_DIR})
endif()

be_target_compile_options(backtesting_engine_shared)

set_target_properties(backtesting_engine_shared PROPERTIES
    OUTPUT_NAME backtesting_engine
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
)

# CLI executable
add_executable(backtest_engine
    src/main.cpp
    ${CLI_SOURCES}
)

target_link_libraries(backtest_engine PRIVATE BacktestingEngine::backtesting_engine_shared)

be_target_compile_options(backtest_engine)

# Set runtime path for shared libraries
set_target_properties(backtest_engine PROPERTIES
    INSTALL_RPATH_USE_LINK_PATH TRUE
)

# HTTP Server executable for deployment
add_executable(backtest_server
    src/server.cpp
)

target_link_libraries(backtest_server PRIVATE BacktestingEngine::backtesting_engine_shared)

# `server.cpp` directly uses libcurl entry points, so link curl explicitly.
target_link_libraries(backtest_server PRIVATE
    CURL::libcurl
    yaml-cpp::yaml-cpp
    Threads::Threads
)

be_target_compile_options(backtest_server)

# Set runtime path for shared libraries
set_target_properties(backtest_server PROPERTIES
    INSTALL_RPATH_USE_LINK_PATH TRUE
)

add_executable(test_csv_date_filter
    tests/csv_data_handler_date_filter_test.cpp
    ${CORE_SOURCES}
)

add_executable(test_risk_exposure_units
    tests/risk_exposure_units_test.cpp
    ${CORE_SOURCES}
)

target_include_directories(test_csv_date_filter PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)
target_include_directories(test_risk_exposure_units PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(test_csv_date_filter
    PRIVATE
    Eigen3::Eigen
    spdlog::spdlog
    CURL::libcurl
    yaml-cpp::yaml-cpp
    nlohmann_json::nlohmann_json
    Threads::Threads
)

target_link_libraries(test_risk_exposure_units
    PRIVATE
    Eigen3::Eigen
    spdlog::spdlog
    CURL::libcurl
    yaml-cpp::yaml-cpp
    nlohmann_json::nlohmann_json
    Threads::Threads
)

add_test(NAME test_csv_date_filter COMMAND test_csv_date_filter)
add_test(NAME test_risk_exposure_units COMMAND test_risk_exposure_units)

# Examples
option(BACKTESTINGENGINE_BUILD_EXAMPLES "Build example programs" ON)
if(BACKTESTINGENGINE_BUILD_EXAMPLES)
    add_executable(example_yfinance_usage examples/yfinance_usage_example.cpp)
    target_link_libraries(example_yfinance_usage PRIVATE BacktestingEngine::backtesting_engine_shared)

    add_executable(example_csv_library_usage examples/csv_library_usage_example.cpp)
    target_link_libraries(example_csv_library_usage PRIVATE BacktestingEngine::backtesting_engine_shared)
endif()

# Install library + headers + executables
install(TARGETS backtesting_engine_shared backtest_engine backtest_server
    EXPORT BacktestingEngineTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# CMake package export (find_package)
install(EXPORT BacktestingEngineTargets
    NAMESPACE BacktestingEngine::
    FILE BacktestingEngineTargets.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/BacktestingEngine
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/BacktestingEngineConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/BacktestingEngineConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/BacktestingEngine
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/BacktestingEngineConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/BacktestingEngineConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/BacktestingEngineConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/BacktestingEngine
)

# CPack configuration
set(CPACK_PACKAGE_NAME "BacktestingEngine")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION "High-performance C++ backtesting engine with advanced analytics and machine learning capabilities")
include(CPack)
