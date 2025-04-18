{
  packages = {
    settings_api = {
      dependencies = {
      },
      files = {
        settings_api = {
          upstream = "cc_extensions/apis/settings",
          fs = ".tami/cc/apis/settings"
        },
        expect_module = {
          upstream = "cc_extensions/modules/main/cc/expect.lua",
          fs = ".tami/cc/modules/main/cc/expect.lua"
        },
        startup = {
          upstream = "cc_extensions/settings_startup.lua",
          fs = ".tami/startups/001-settings_api.lua"
        }
      }
    },
    RootFS_lib = {
      files = {
        boot = {
          upstream = "packages/lib/RootFS.lua",
          fs = ".tami/lib/RootFS"
        },
        startup = {
          upstream = "packages/lib/load_RootFS.lua",
          fs= ".tami/startups/000-RootFS_lib.lua"
        }
      }
    },
    download = {
      dependencies = {
        "settings_api"
      },
      files = {
        bin = {
          upstream = "packages/download/download.lua",
          fs = ".tami/bin/download"
        },
        startup = {
          upstream = "packages/download/download_comp.lua",
          fs = ".tami/startups/001-download.lua"
        }
      }
    },
    phone = {
      files = {
        upstream = "packages/phone/main.lua",
        fs = ".tami/bin/phone"
      }
    },
    swarm_mother = {
      dependencies = {
        "astar_lib"
      },
      files = {
        bin = {
          upstream = "packages/swarm_mother/main.lua",
          fs = ".tami/bin/swarm_mother"
        },
        startup = {
          upstream = "packages/swarm_mother/startup.lua",
          fs = ".tami/startups/050-swarm_mother.lua"
        }
      }
    },
    status = {
      files = {
        bin = {
          upstream = "packages/mainframe/status.lua",
          fs = ".tami/bin/status"
        }
      }
    },
    core = {
      dependencies = {
        "RootFS_lib"
      },
      files = {
        boot = {
          upstream = "boot.lua",
          fs = ".tami/boot.lua"
        }
      }
    },
    test = {
      dependencies = {
        "test_2"
      },
      files = {
        boot = {
          upstream = "packages/test/test.lua",
          fs = "test"
        }
      }
    },
    test_2 = {
      files = {
        boot = {
          upstream = "packages/test/test_2.lua",
          fs = "test_2"
        }
      }
    },
    astar_lib = {
      files = {
        lib = {
          upstream = "packages/lib/astar.lua",
          fs = ".tami/lib/astar"
        }
      }
    },
    gurl = {
      dependencies = {
        "download",
        "RootFS_lib"
      },
      files = {
        bin = {
          upstream = "packages/gurl/gurl.lua",
          fs = ".tami/bin/gurl"
        },
        startup = {
          upstream = "packages/gurl/gurl_startup.lua",
          fs = ".tami/startups/050-gurl.lua"
        }
      }
    }
  }
}
