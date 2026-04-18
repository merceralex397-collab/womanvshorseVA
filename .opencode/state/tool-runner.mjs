import { pathToFileURL } from "node:url"
const toolPath = process.env.SCAFFORGE_TOOL_PATH
if (!toolPath) throw new Error('Missing SCAFFORGE_TOOL_PATH')
const mod = await import(pathToFileURL(toolPath).href)
const rawArgs = process.env.SCAFFORGE_TOOL_ARGS || '{}'
const payload = await mod.default.execute(JSON.parse(rawArgs))
console.log(payload)
