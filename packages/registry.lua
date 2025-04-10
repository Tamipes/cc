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
          fs = ".tami/startups/settings_api.lua"
        }
      }
    },
    RootFS_lib = {
      files = {
        boot = {
          upstream = "lib/RootFS.lua",
          fs = ".tami/lib/RootFS"
        },
        startup = {
          upstream = "lib/load_RootFS.lua",
          fs= ".tami/startups/RootFS_lib.lua"
        }
      }
    },
    download = {
      dependencies = {
        "settings_api"
      },
      files = {
        bin = {
          upstream = "pastebin/download.lua",
          fs = ".tami/bin/download"
        },
        comp = {
          upstream = "pastebin/download_comp.lua",
          fs = ".tami/startups/download.lua"
        }
      }
    },
    status = {
      files = {
        bin = {
          upstream = "mainframe/status.lua",
          fs = ".tami/bin/status"
        }
      }
    },
    core = {
      files = {
        boot = {
          upstream = "packages/boot.lua",
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
          upstream = "test.lua",
          fs = "test"
        }
      }
    },
    test_2 = {
      files = {
        boot = {
          upstream = "test_2.lua",
          fs = "test_2"
        }
      }
    },
    astar_lib = {
      files = {
        startup = {
          upstream = "lib/astar.lua",
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
          upstream = "packages/gurl.lua",
          fs = ".tami/bin/gurl"
        },
        startup = {
          upstream = "packages/gurl_startup.lua",
          fs = ".tami/startups/gurl.lua"
        }
      }
    }
  }
}
