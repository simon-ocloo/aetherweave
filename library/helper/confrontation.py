import torch

from .shell import print_message



def confrontation(workflow_name: str, actual: torch.Tensor, expected: torch.Tensor, atol: float = 1e-6):
    if not torch.allclose(actual, expected, atol=atol):
        raise RuntimeError(
            f"output mismatch\nexpected: {expected}\ngot:      {actual}"
        )
    max_err = (actual - expected).abs().max().item()
    print_message(workflow_name, f"OK — {actual.numel()} elements verified (max err: {max_err:.2e})")
