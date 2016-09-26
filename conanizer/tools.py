import shutil
import tempfile
import os


def process_port(port, tmp_folder, visual_version, build_type):
    try:
        print("Processing... %s:%s" % (port.source, port.version))
        tmp_folder = os.path.join(tmp_folder, port.name)        
        new_template_to(port.name, port.version, tmp_folder)
        command = "cd %s && conan test_package -s compiler=\"Visual Studio\" -s compiler.version=%s -s build_type=%s" % (tmp_folder, visual_version, build_type)
        print(command)
        ret = os.system(command)
        return ret == 0
    except Exception as exc:
        print("%s: Error '%s'" % (port.name, exc))
        return False

def temp_folder():
    return tempfile.mkdtemp(suffix='vcpkg_conanizer')

def replace_in_file(file_path, search, replace):
    with open(file_path, 'rt') as content_file:
        content = content_file.read()
        content = content.replace(search, replace)
    with open(file_path, 'wt') as handle:
        handle.write(content)


def new_template_to(name, version, dest_dir):
    shutil.copytree(os.path.abspath("./conanizer/template"), dest_dir)
    shutil.copytree(os.path.abspath("./ports/%s" % name), os.path.join(dest_dir, "vcpkg/ports/%s" % name))
    shutil.copytree(os.path.abspath("./scripts"), os.path.join(dest_dir, "vcpkg/scripts"))
    shutil.copytree(os.path.abspath("./triplets"), os.path.join(dest_dir, "vcpkg/triplets"))
    shutil.copy(os.path.abspath("./.vcpkg-root"), os.path.join(dest_dir, "vcpkg/.vcpkg-root"))
    
    replace_in_file(os.path.join(dest_dir, "conanfile.py"), "**NAME**", name)
    replace_in_file(os.path.join(dest_dir, "conanfile.py"), "**VERSION**", version)
    replace_in_file(os.path.join(dest_dir, "test_package/conanfile.py"), "**NAME**", name)
    replace_in_file(os.path.join(dest_dir, "test_package/conanfile.py"), "**VERSION**", version)