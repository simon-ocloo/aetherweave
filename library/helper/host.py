import platform



def cpu_architecture() -> str:
    machine = platform.machine()
    if machine in ("x86_64", "AMD64"):
        return "x86_64"
    if machine in ("aarch64", "arm64"):
        return "aarch64"
    return machine
