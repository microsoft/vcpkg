import os
import os.path
import sys
import subprocess
import json

from subprocess import CalledProcessError
from json.decoder import JSONDecodeError

def generate_port_versions_db(dir_path):
    port_names = [item for item in os.listdir('../ports') if os.path.isdir(os.path.join('../ports', item))]
    for counter, port_name in enumerate(port_names):    
        output_filepath = os.path.join(dir_path, '{}.db.json'.format(port_name))
        if (counter % 100) == 0:
            print('Processed {} out of {}'.format(counter, len(port_names)))
        if not os.path.exists(output_filepath):            
            try:
                output = subprocess.run(args=['../vcpkg.exe', 'x-history', port_name, '--x-json'], capture_output=True)
                try:
                    versions_object = json.loads(output.stdout)
                    with open(output_filepath, 'w') as output_file:
                        json.dump(versions_object, output_file)
                except JSONDecodeError as json_err:
                    print('Failed to load JSON for {}'.format(port_name))
            except CalledProcessError as err:
                print("Failed to run {}".format(err.cmd)) 


def main(dir_path):
    try:
        os.mkdir(dir_path)
    except FileExistsError:
        print("Path already exists, continuing...")

    generate_port_versions_db(dir_path)


if __name__ == "__main__":
    main('port_versions_db')