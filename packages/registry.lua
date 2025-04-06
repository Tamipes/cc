{
  packages = {
    core = {
      dependencies = {
        "download"
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
      files = {
        bin = {
          upstream = "packages/gurl.lua",
          fs = ".tami/bin/gurl"
        }
      }
    }
  }
}
