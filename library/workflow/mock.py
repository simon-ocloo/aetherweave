from library.helper import execute, print_header



def run():
    workflow_name = "MOCK"

    print_header(workflow_name)
    execute(workflow_name, "./bin/aw-compile", check=False)
    execute(workflow_name, "./bin/aw-execute", check=False)
