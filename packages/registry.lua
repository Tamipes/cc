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
    gurl = {
      dependencies = {
        "download"
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
