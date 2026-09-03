from library.helper import execute, print_header



def run():
    workflow_name = "MOCK"

    print_header(workflow_name)
    execute(workflow_name, "aw-compile")
    execute(workflow_name, "aw-execute")
