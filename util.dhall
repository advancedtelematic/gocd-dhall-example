-- Useful functions to share across the repo
let Types = ./types.dhall

let manualApproval : Optional Types.Approval =
  Some { type = "manual" }

let autoApproval = None Types.Approval

let createJob =
  \(name : Text) -> \(tasks : List Types.Task) -> \(artifacts : Optional (List Types.Artifact)) -> \(elastic_profile_id : Optional Text) ->
    { mk = name
    , mv =
      { tasks = tasks
      , artifacts = artifacts
      , elastic_profile_id = elastic_profile_id
      }
    } : Types.Job

in
{ manualApproval = manualApproval
, autoApproval = autoApproval
, createJob = createJob
}
