import subprocess
import re
import os

def kill_processes_on_port(port):
    # Get the list of all processes listening on the specified port
    try:
        result = subprocess.check_output(f"sudo lsof -t -i:{port}", shell=True).decode('utf-8').strip()
    except subprocess.CalledProcessError:
        print(f"No process found listening on port {port}")
        return

    if result:
        pids = result.split('\n')
        for pid in pids:
            try:
                # Kill each process found using PID
                subprocess.run(['sudo', 'kill', '-9', pid], check=True)
                print(f"Process {pid} on port {port} has been killed.")
            except subprocess.CalledProcessError as e:
                print(f"Failed to kill process {pid}. Error: {e}")

    else:
        print(f"No process found listening on port {port}")

if __name__ == "__main__":
    port = 40490
    kill_processes_on_port(port)
