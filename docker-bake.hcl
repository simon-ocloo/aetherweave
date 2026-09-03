group "default" {
  targets = ["aetherweave"]
}

target "aetherweave-compiler" {
  context    = "./aetherweave-compiler"
  dockerfile = "Dockerfile"
  tags       = ["aetherweave-compiler:latest"]
}

target "aetherweave-executor" {
  context    = "./aetherweave-executor"
  dockerfile = "Dockerfile"
  tags       = ["aetherweave-executor:latest"]
}

target "aetherweave" {
  context    = "."
  dockerfile = "Dockerfile"
  tags       = ["aetherweave:latest"]
  contexts = {
    compiler-stage = "target:aetherweave-compiler"
    executor-stage = "target:aetherweave-executor"
  }
}
