-- math.randomseed(os.time())
local present, impatient = pcall(require, "impatient")

if present then
  impatient.enable_profile()
end

require("kide.core")
require("kide.plugins")
