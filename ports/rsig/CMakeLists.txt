cmake_minimum_required(VERSION 3.8)
project(rsig VERSION 0.1.0 LANGUAGES CXX)

set(HEADERS_rsig
	rsig/rsig.h
)

install(FILES rsig/rsig.h DESTINATION include/rsig)
