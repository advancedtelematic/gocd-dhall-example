let map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/0a7f596d03b3ea760a96a8e03935f4baa64274e1/Prelude/List/map
let Types = ./types.dhall
let Service = ./service.dhall
let util = ./util.dhall
let variables = ./variables.dhall

-- Trigger this job manually
let manualStage : Types.Stage =
  { mk = "manual"
  , mv =
    { clean_workspace = True
    , approval = util.manualApproval
    , jobs =
      [ { mk = "manual"
        , mv =
          { elastic_profile_id = variables.elastic_profile_id
          , artifacts = None (List Types.Artifact)
          , tasks =
            [ Types.Task.Script { script = "echo 'Pipeline has been triggered'" } ]
          }
        }
      ]
    }
  }

-- Fetch the version for a given service
let createFetchTask : Service -> Types.Task =
  \(service : Service) ->
  Types.Task.Fetch
  { fetch =
    { pipeline = "${service.name}-release"
    , stage = "deploy"
    , job = "${service.name}"
    , source = "artifact-dir/${service.name}-version.txt"
    , is_file = True
    }
  }

-- Map over the list of services, and create a fetch task for it's version
let fetchTasks = map Service Types.Task createFetchTask variables.services
let testTasks =
  fetchTasks
  # [ Types.Task.Script { script = "./scripts/end-to-end-test.sh" } ]

-- The file the tests output
let testArtifact = Some [ { build = { source = "test-results.txt", destination = "artifact-dir" } } ]

-- Wrap these up in a GoCD job
let testJob =
  util.createJob "test" testTasks testArtifact variables.elastic_profile_id

-- Create the materials for each service so the fetch task will work
let createPipelineMaterials =
  \(service : Service) ->
  { mk = "${service.name}-version"
  , mv =
    Types.Material.Pipeline
    { pipeline = "${service.name}-release"
    , stage = "deploy"
    }
  }
let pipelineMaterials = map Service Types.MaterialMap createPipelineMaterials variables.services

-- The end-to-end-test pipeline
let pipeline =
  { mk = "test-env"
  , mv =
    { stages =
      [ [ manualStage ]
      , [ { mk = "test"
          , mv =
            { clean_workspace = True
            , approval = util.autoApproval
            , jobs =
              [ testJob ]
            }
          }
        ]
      ]
    , group = "end-to-end-test"
    , environment_variables =
      Some
      [ { mk = "URL", mv = "https://example.com" }
      ]
    , parameters = None Types.ListKV
    , materials = pipelineMaterials
        # [ { mk = "end-to-end-test-repo"
            , mv =
              Types.Material.Source
              { git = variables.end-to-end-test-repo
              , branch = "master"
              , destination = None Text
              , auto_update = True
              }
            }
          ]
    }
  } : Types.Pipeline

in pipeline
