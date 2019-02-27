-- Based on the spec here
-- https://github.com/tomzo/gocd-yaml-config-plugin#specification

let KV     = { mk : Text, mv : Text }
let ListKV = List KV
let Artifact =
  { build :
    { source : Text
    , destination: Text
    }
  }

let MaterialSource =
  { git : Text
  , branch : Text
  , auto_update : Bool
  , destination : Optional Text }

let MaterialPipeline = { pipeline : Text, stage : Text }

let Material = < Source : MaterialSource | Pipeline : MaterialPipeline >

let MaterialMap = { mk : Text, mv : Material }
let Materials = List MaterialMap

let TaskScript = {script: Text}
let TaskFetch =
  { fetch :
    { is_file : Bool
    , job : Text
    , pipeline : Text
    , stage : Text
    , source : Text
    }
  }
let Task = < Script : TaskScript | Fetch : TaskFetch >

let Job =
  { mk : Text
  , mv :
    { tasks : List Task
    , elastic_profile_id : Optional Text
    , artifacts : Optional (List Artifact)
    }
  }

let Approval =
{ type : Text }

let Stage =
  { mk : Text
  , mv :
    { clean_workspace : Bool
    , approval : Optional Approval
    , jobs : List Job
    }
  }

let Stages = List (List Stage)

let Pipeline =
  { mk : Text
  , mv :
    { stages : Stages
    , group : Text
    , environment_variables : Optional ListKV
    , parameters : Optional ListKV
    , materials : Materials
    }
  }

let Pipelines = { pipelines : List Pipeline }

let Environment =
  { mk : Text
  , mv :
    { environment_variables : Optional ListKV
    , secure_variables : Optional ListKV
    , pipelines : List Text
    }
  }

let Environments = { environments : List Environment}

in
  { KV = KV
  , ListKV = ListKV
  , MaterialMap = MaterialMap
  , Material = Material
  , Materials = Materials
  , Artifact = Artifact
  , Approval = Approval
  , Task = Task
  , Job = Job
  , Stage = Stage
  , Pipeline = Pipeline
  , Pipelines = Pipelines
  , Environment = Environment
  , Environments = Environments
  }
