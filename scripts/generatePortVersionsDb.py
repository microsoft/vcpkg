import os
import os.path
import sys
import subprocess
import json
import time

from subprocess import CalledProcessError
from json.decoder import JSONDecodeError
from pathlib import Path


SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))


def get_current_git_ref():
    try: 
        output = subprocess.run(args=['git.exe', 'rev-parse', '--verify', 'HEAD'], capture_output=True)
        if output.returncode == 0:
            return output.stdout.decode('utf-8').strip()
        return ''
    except CalledProcessError as err:
        print(f"Failed to get git ref.\n{err}\n", file=sys.stderr)


def generate_port_versions_db(ports_path, db_path, revision):
    start_time = time.time()

    port_names = [item for item in os.listdir(ports_path) if os.path.isdir(os.path.join(ports_path, item))]
    total_count = len(port_names)
    for counter, port_name in enumerate(port_names):
        containing_dir = os.path.join(db_path, f'{port_name[0]}-')
        os.makedirs(containing_dir, exist_ok=True)
        
        output_filepath = os.path.join(containing_dir, f'{port_name}.json')
        if not os.path.exists(output_filepath):            
            try:
                output = subprocess.run(args=['../vcpkg.exe', 'x-history', port_name, '--x-json'], capture_output=True)
                try:
                    versions_object = json.loads(output.stdout)
                    with open(output_filepath, 'w') as output_file:
                        json.dump(versions_object, output_file)
                except JSONDecodeError as json_err:
                    print(f'Failed to load JSON for {port_name}.\n{json_err}\n', file=sys.stderr)
            except CalledProcessError as err:
                print(f"Failed to run.\n{err.cmd}\n", file=sys.stderr) 

        # This should be replaced by a progress bar
        if counter > 0 and counter % 100 == 0:
            elapsed_time = time.time() - start_time
            print(f'Processed {counter} out of {total_count}. Elapsed time: {elapsed_time:.2f} seconds')
    
    rev_file = os.path.join(db_path, revision)
    Path(rev_file).touch()
    elapsed_time = time.time() - start_time
    print(f'Processed {total_count} total ports. Elapsed time: {elapsed_time:.2f} seconds')
    

def main(ports_path, db_path):
    revision = get_current_git_ref()

    if not revision:
        print('Couldn\'t fetch current Git revision', file=sys.stderr)
        sys.exit(1)

    rev_file = os.path.join(db_path, revision)
    if os.path.exists(rev_file):
        print(f'Database files already exist for commit {revision}')
        sys.exit(0)
    
    generate_port_versions_db(ports_path, db_path, revision)


if __name__ == "__main__":
    main(ports_path=os.path.join(SCRIPT_DIRECTORY, '../ports'), 
        db_path=os.path.join(SCRIPT_DIRECTORY, '../port_versions'))