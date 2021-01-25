Kind = "service-router"
Name = "country-api"
Routes = [
  {
    match = {
      http = {
    path_prefix = "/api/japan"
      }
  }
    destination = {
      service = "japan"
    }
  },

  {
    match = {
      http = {
    path_prefix = "/api/france"
      }
  }
    destination = {
      service = "france"
    }
  },
]