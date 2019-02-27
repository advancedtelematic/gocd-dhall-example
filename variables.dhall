let Types = ./types.dhall
let Service = ./service.dhall

-- address of the local gitlab server, as started by the Makefile
let localRepoUrl = "http://gitlab.example.com:30080/root/gocd-dhall-example.git"

in
  { services =
    [ { name = "frontend"
      , repo = localRepoUrl -- For this example project, all the services use this repo
      }
    , { name = "backend"
      , repo = localRepoUrl
      }
    -- Uncomment the following block to add another service
    {-
    , { name = "another-service"
      , repo = localRepoUrl
      }
    -}
    ] : List Service
  , elastic_profile_id = None Text
  , end-to-end-test-repo = localRepoUrl
  , format_version = 2
  }
