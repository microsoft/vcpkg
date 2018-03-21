import re
import json
import sys
import os
from subprocess import Popen, PIPE

doc = open(sys.argv[1]).read()
packages = json.loads(doc)

bincrafternames = [re.sub("^lib","",package['massaged_name']) for package in packages]

# hand-rolled replacements
replacements = {
    "mysql-connector-c": "mysql",
    "gsl-microsoft": "ms-gsl",
    "glfw":"glfw3",
    "zmq":"zeromq",
    "tinydnn":"tiny-dnn",
    "boost-numeric-ublas":"boost-ublas",
    "boost-numeric-interval":"boost-interval",
    "boost-numeric-odeint":"boost-odeint",
    "openal":"openal-soft",
    "pthreads4w":"pthreads",
}

skips = [
    ".*-installer$",
    "boost-generator",
    "boost-level5group",
    "readme-generator",
    "cmake-findboost-modular",
    "boost-level11group",
    "boost-level8group",
    "azure-iot-sdk-demo-conan",
    "boost-level14group",
    "community",
    "winflexbison",
    "bincrafters.github.io",
    "templates",
    "gyp",
    "bison",
    "vs-extension",
    "changelog",
    "emd",
    "flex",
    "envy",
    "jfrog-cli-go",
    "boost-package-tools",
    "git-ws",
    "go-bin-deb",
    "go-bin-rpm",
    "go-msi",
    "gump",
]

names = []
for name in bincrafternames:
    if name in replacements:
        names.append(replacements[name])
        continue
    
    found = False
    for skip in skips:
        if re.match(skip, name):
            print("Skipping {} because {}".format(name, skip))
            found = True
            break

    if not found:
        names.append(name)

vcpkg_raw_search = []
with Popen(["vcpkg", "search", "--x-full-desc"], stdout=PIPE, bufsize=1, universal_newlines=True) as p:
    vcpkg_raw_search = [line.strip() for line in p.stdout]

vcpkg_names = []
for line in vcpkg_raw_search:
    m = re.match(r"([a-z0-9-]+) .+", line)
    if m:
        vcpkg_names.append(re.sub("^lib","",m.group(1)))

vcpkg_names_set = set(vcpkg_names)
names_set = set(names)

print("Intersection")
for k in sorted(list(vcpkg_names_set.intersection(names_set))):
    print("    {}".format(k))

print("Only in Bincrafters")
for k in sorted(list(names_set.difference(vcpkg_names_set))):
    print("    {}".format(k))
