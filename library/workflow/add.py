import json
import os
import shutil
import tempfile

import numpy
import torch

from library.helper import artifact_name, confrontation, cpu_architecture, execute, print_header, print_message



class _AddModel_(torch.nn.Module):

    def forward(self, x: torch.Tensor, y: torch.Tensor) -> torch.Tensor:
        return torch.add(x, y)


def run():
    workflow_name = "ADD"

    print_header(workflow_name)
    torch.manual_seed(0)

    with tempfile.TemporaryDirectory() as temporary_directory:
        debug_directory_path = os.environ.get("AETHERWEAVE_DEBUG_DIRECTORY_PATH") or None
        try:
            model_path    = os.path.join(temporary_directory, "add.onnx")
            artifact_path = os.path.join(temporary_directory, artifact_name("add"))
            x_path        = os.path.join(temporary_directory, "x.bin")
            y_path        = os.path.join(temporary_directory, "y.bin")
            z_path        = os.path.join(temporary_directory, "z.bin")

            # --- Export ONNX from PyTorch ---
            model   = _AddModel_().eval()
            shape   = (8,)
            x_dummy = torch.zeros(*shape)
            y_dummy = torch.zeros(*shape)

            torch.onnx.export(
                model,
                (x_dummy, y_dummy),
                model_path,
                input_names=["x", "y"],
                output_names=["z"],
                opset_version=20,
                dynamo=False,
            )
            print_message(workflow_name, f"ONNX exported → {model_path}")

            # --- Generate inputs + reference output ---
            x     = torch.randn(*shape)
            y     = torch.randn(*shape)
            z_cpu = model(x, y)

            x.numpy().astype(numpy.float32).tofile(x_path)
            y.numpy().astype(numpy.float32).tofile(y_path)

            # --- Compile ---
            compile_configuration_path = os.path.join(temporary_directory, "compile_configuration.json")

            with open(compile_configuration_path, "w") as file:
                json.dump({
                    "debug_mode":           debug_directory_path is not None,
                    "debug_directory_path": debug_directory_path,
                    "import_path":          model_path,
                    "export_path":          artifact_path,
                    "target": {
                        "device":           "CPU",
                        "architecture":     cpu_architecture(),
                    },
                }, file, indent=4)
            execute(workflow_name, "./bin/aw-compile", compile_configuration_path)

            # --- Execute ---
            execute_configuration_path = os.path.join(temporary_directory, "execute_configuration.json")

            with open(execute_configuration_path, "w") as file:
                json.dump({
                    "debug_mode":           debug_directory_path is not None,
                    "debug_directory_path": debug_directory_path,
                    "import_path":          artifact_path,
                    "mode":                 "inference",
                    "inputs":               [x_path, y_path],
                    "outputs":              [z_path],
                }, file, indent=4)
            execute(workflow_name, "./bin/aw-execute", execute_configuration_path)

            # --- Confrontation ---
            if os.path.exists(z_path):
                z_aw = torch.from_numpy(numpy.fromfile(z_path, dtype=numpy.float32))
                confrontation(workflow_name, z_aw, z_cpu)
            else:
                print_message(workflow_name, f"skipping confrontation, output file not found: {z_path}")

        finally:
            if debug_directory_path is not None:
                shutil.copytree(temporary_directory, debug_directory_path, dirs_exist_ok=True)
                print_message(workflow_name, f"debug directory path: {debug_directory_path}")
