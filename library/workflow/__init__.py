from . import add
from . import mock



def run(name: str, **kwargs):
    workflows = {
        "add":  add.run,
        "mock": mock.run,
    }

    workflows[name]()
