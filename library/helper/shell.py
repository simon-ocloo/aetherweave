import subprocess



def execute(workflow_name: str, *args: str, check: bool = True) -> int:
    print(f"[{workflow_name}]> {' '.join(args)}", flush=True)
    result = subprocess.run(args)
    if check and result.returncode != 0:
        raise RuntimeError(f"{args[0]} failed (exit {result.returncode})")
    return result.returncode


def print_header(name: str):
    width  = 80
    inner  = width - 2
    top    = "╔" + "═" * inner + "╗"
    label  = "║  " + f"{name.upper()} Workflow".ljust(inner - 2) + "║"
    bottom = "╚" + "═" * inner + "╝"
    print(f"{top}\n{label}\n{bottom}", flush=True)


def print_message(workflow_name: str, message: str):
    print(f"[{workflow_name}] {message}", flush=True)
