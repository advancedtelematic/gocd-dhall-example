let variables = ./variables.dhall

in
{ format_version = variables.format_version
, pipelines =
    ./build-test-deploy.dhall           -- import the build/test/deploy pipelines
    # [./end-to-end-test.dhall]         -- import the end to end test pipeline
, environments = ./environments.dhall   -- import the environments
}
