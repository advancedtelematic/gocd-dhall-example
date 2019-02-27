let map = https://raw.githubusercontent.com/dhall-lang/dhall-lang/0a7f596d03b3ea760a96a8e03935f4baa64274e1/Prelude/List/map

let Types = ./types.dhall
let Service = ./service.dhall
let variables = ./variables.dhall

-- map over the list of variables, and create the list of pipeline names to add to the environment.
let releasePipelines =
  map Service Text (\(service : Service) -> "${service.name}-release") variables.services

let environments =
[ { mk = "release"
  , mv =
    { pipelines = releasePipelines
    , environment_variables =
      Some
      [ { mk = "BUILD_CREDS", mv = "foo:bar" } -- Some example variable
      ]
    , secure_variables = None Types.ListKV
    }
  }
, { mk = "end-to-end"
  , mv =
    { pipelines = [ "test-env" ]
    , environment_variables =
      Some
      [ { mk = "TEST_USER_CREDS", mv = "baz:buz" } -- Some example variable
      ]
    , secure_variables = None Types.ListKV
    }
  }
] : List Types.Environment

in environments
