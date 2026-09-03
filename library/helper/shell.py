import subprocess



def execute(workflow_name: str, *args: str) -> int:
    print(f"[{workflow_name}]> {' '.join(args)}", flush=True)
    result = subprocess.run(args)
    return result.returncode


def print_header(name: str):
    width  = 80
    inner  = width - 2
    top    = "╔" + "═" * inner + "╗"
    label  = "║  " + f"{name.upper()} Workflow".ljust(inner - 2) + "║"
    bottom = "╚" + "═" * inner + "╝"
    print(f"{top}\n{label}\n{bottom}", flush=True)
