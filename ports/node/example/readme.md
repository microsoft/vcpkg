# Purpose
How to compile v8 embedded sample process.cc with libnode
# Guide
## Step 1: Download process.cc from <https://raw.githubusercontent.com/v8/v8/main/samples/process.cc>
```bash
# the latest nodejs use v8 11.8.172.13
wget https://raw.githubusercontent.com/v8/v8/11.8.172.13/samples/process.cc
wget https://raw.githubusercontent.com/v8/v8/11.8.172.13/samples/count-hosts.js
```
## Step 2: minor fix process.cc to process-fix.cc
```bash
sed 's|#include "include/|#include "|g' process.cc > process-fix.cc
```
## Step 3: Compile process.cc with libnode
```bash
cmake -S . -B build
cmake --build build
```
## Step 4: Run the compiled process
```bash
#./build/process
cmake --build build --target test
```

### Tips:
you may need:

```bash
cmake --build build  --target clean
cmake --build build  
cmake --build build  --target test
```


# Refs
1. https://nodejs.org/api/embedding.html
2. https://v8.dev/docs/embed
3. https://raw.githubusercontent.com/v8/v8/main/samples/process.cc
4. https://chromium.googlesource.com/v8/v8/+/refs/heads/lkgr/test/cctest/test-api-interceptors.cc



