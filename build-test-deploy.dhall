let map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/0a7f596d03b3ea760a96a8e03935f4baa64274e1/Prelude/List/map -- import the dhall map function from github

let Types = ./types.dhall     -- the file that defines the GoCD YAML types
let Service = ./service.dhall -- an type definition specific to this example

let variables = ./variables.dhall
let util = ./util.dhall

--
-- Build the project
--
-- the steps that it takes to build this example project
let buildTasks
    : Service → List Types.Task
    =   λ(service : Service)
      → [ Types.Task.Script { script = "echo 'starting to build ${service.name}'" }
        , Types.Task.Script { script = "./scripts/build.sh ${service.name}" }
        ]

-- Your build artifact. In this example it's a git SHA from written to a file by `./scripts/build.sh`
let versionArtifact : Service -> Optional (List Types.Artifact) =
  λ(service : Service) ->
  Some [ { build = { source = "${service.name}-version.txt", destination = "artifact-dir" } } ]

-- Wrap these up in a GoCD job
let buildJob
    : Service → Types.Job
    = λ(service : Service)
      -> util.createJob service.name (buildTasks service) (versionArtifact service) variables.elastic_profile_id

--
-- Test the project
--
-- The "tests" that are run
let testTasks
    : Service → List Types.Task
    =   λ(service : Service)
      → [ Types.Task.Script { script = "echo 'testing ${service.name}'" }
        , Types.Task.Script { script = "./scripts/test.sh" }
        ]

-- The test results file
let testArtifact = Some [ { build = { source = "test-results.txt", destination = "artifact-dir" } } ]

-- Wrap these up in a GoCD job
let testJob
    : Service → Types.Job
    = λ(service : Service)
      -> util.createJob service.name (testTasks service) testArtifact variables.elastic_profile_id

--
-- Deploy the project
--
-- Grabs the version from the build job and then runs the deploy script
let deployTasks
    : Service → List Types.Task
    =   λ(service : Service)
      → [ Types.Task.Fetch
          { fetch =
            { pipeline = "${service.name}-release"
            , stage = "build"
            , job = "${service.name}"
            , source = "artifact-dir/${service.name}-version.txt"
            , is_file = True
            }
          }
        , Types.Task.Script { script = "echo 'deploying ${service.name}'" }
        , Types.Task.Script { script = "./scripts/deploy.sh ${service.name}" }
        ]

-- Wrap these up in a GoCD job
let deployJob
    : Service → Types.Job
    = λ(service : Service)
      -> util.createJob service.name (deployTasks service) (versionArtifact service) variables.elastic_profile_id

-- function that takes a Service (like from the list in `./variables.dhall`) and
-- and returns a GoCD pipeline
let mkPipelines : Service → Types.Pipeline =
  λ(service : Service) →
  { mk = "${service.name}-release"
  , mv =
    { stages =
      [ [ { mk = "build"
          , mv =
            { clean_workspace = False
            , approval = util.autoApproval
            , jobs =
              [ buildJob service ]
            }
          }
        ]
      , [ { mk =
              "test"
          , mv =
            { clean_workspace = False
            , approval = util.autoApproval
            , jobs =
              [ testJob service ]
            }
          }
        ]
      , [ { mk =
              "deploy"
          , mv =
            { clean_workspace = False
            , approval = util.autoApproval
            , jobs =
              [ deployJob service ]
            }
          }
        ]
      ]
    , group = service.name
    , environment_variables = None Types.ListKV
    , parameters = None Types.ListKV
    , materials =
      [ { mk = "${service.name}-repo"
        , mv =
          Types.Material.Source
          { git = service.repo
          , branch = "master"
          , destination = None Text
          , auto_update = True
          }
        }
      ]
    }
  }

-- map over the list of services, and create a pipeline for each
let pipelines =
  map Service Types.Pipeline mkPipelines variables.services
  # [./end-to-end-test.dhall]

-- export the finished pipelines
in pipelines
