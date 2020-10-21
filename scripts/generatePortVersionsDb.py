import os
import os.path
import sys
import subprocess
import json
import time

from subprocess import CalledProcessError
from json.decoder import JSONDecodeError
from pathlib import Path

def make_dir(dir_path):
    if not os.path.exists(dir_path):
            os.makedirs(dir_path)


def get_current_git_ref():
    try: 
        output = subprocess.run(args=['git.exe', 'rev-parse', '--verify', 'HEAD'], capture_output=True)
        if output.returncode == 0:
            return output.stdout.decode('utf-8').strip()
        return ''
    except CalledProcessError as err:
        print("Failed to get git ref")


def generate_port_versions_db(ports_path, db_path, revision):
    start_time = time.time()

    port_names = [item for item in os.listdir(ports_path) if os.path.isdir(os.path.join(ports_path, item))]
    total_count = len(port_names)
    for counter, port_name in enumerate(port_names):
        containing_dir = os.path.join(db_path, port_name[0])
        make_dir(containing_dir)
        
        output_filepath = os.path.join(containing_dir, '{}.json'.format(port_name))
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

        # This should be replaced by a progress bar
        if counter > 0 and counter % 100 == 0:
            elapsed_time = time.time() - start_time
            print('Processed {} out of {}. Elapsed time: {:.2f} seconds'.format(counter, total_count, elapsed_time))
    
    rev_file = os.path.join(db_path, revision)
    Path(rev_file).touch()
    elapsed_time = time.time() - start_time
    print('Processed {} total ports. Elapsed time: {:.2f} seconds'.format(total_count, elapsed_time))
    

def main(ports_path, db_path):
    revision = get_current_git_ref()

    if not revision:
        print('Couldn\'t fetch current Git revision')
        quit()

    rev_file = os.path.join(db_path, revision)
    if os.path.exists(rev_file):
        print('Database files already exist for commit {}'.format(revision))
        quit()
    
    generate_port_versions_db(ports_path, db_path, revision)


if __name__ == "__main__":
    main('../ports', '../port_versions')