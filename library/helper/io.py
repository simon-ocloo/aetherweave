import datetime



def artifact_name(model: str) -> str:
    timestamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")

    return f"artifact.{model}.{timestamp}"
