from . import mock



def run(name: str, **kwargs):
    workflows = {
        "mock": mock.run,
    }

    workflows[name]()
