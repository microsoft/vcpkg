import os
import logging
from . import VCPKG_ROOT_FOLDER
from log import logger
from model import Port
from tools import new_template_to, temp_folder, process_port
from os import getenv


def process_ports(default_ports=None, visual_versions=None):
    ports_dir = os.path.join(VCPKG_ROOT_FOLDER, "ports")
    ports = default_ports or [port for port in os.listdir(ports_dir) if os.path.isdir(os.path.join(ports_dir, port))]
    num_pages = int(getenv("CONAN_TOTAL_PAGES", 10))
    current_page = int(getenv("CONAN_CURRENT_PAGE", 1))
    
    tmp_folder = temp_folder()
    # tmp_folder = "./.tmp"
    
    
    print("Working in folder: %s" % tmp_folder)
    
    visual_versions = visual_versions or [10, 12, 14]
    sorted(ports)
    ports.reverse()
    to_upload = set()
    failed = set()
    
    counter = 0
    # Compile ports
    
    for port_name in ports:
        for visual_version in visual_versions:        
            if counter % num_pages == (current_page - 1):
                for build_type in ["Debug", "Release"]:   
                    logger.info("-------------------------- PROCESSING %s, Visual %s, %s--------------------------" % (port_name, visual_version, build_type))
                    port = Port(port_name, os.path.join(ports_dir, port_name))
                    ok = process_port(port, tmp_folder, visual_version, build_type)
                    if ok:
                        to_upload.add("%s/%s@lasote/vcpkg" % (port.name, port.version))
                    else:
                        failed.add(port.name)    
            counter += 1
    
    return to_upload, failed

def upload_packages(to_upload):
    # Upload packages
    if getenv("CONAN_PASSWORD", None):
        os.system("conan user lasote -p %s" % getenv("CONAN_PASSWORD"))
        for ref in to_upload:
            ret = os.system("conan upload %s --all" % str(ref))
            if ret != 0:
                raise Exception("Error uploading!")
        

if __name__ == "__main__":
    #to_upload, failed = process_ports(["freetype"], [12])
    to_upload, failed = process_ports()
    upload_packages(to_upload)

    print("UPLOADED: %s" % str(to_upload))
    print("FAILED TO BUILD: %s" % str(failed))
