// The guard as a command, for any agent that can run a program before a tool
// call. It reads `{ cwd, tool_input: { command } }` as JSON on stdin and exits
// 2 with the reason on stderr to refuse the call. Claude Code runs judge.ts
// through its mod instead, so judge.ts is a link to the file in that mod:
// Claude's engine won't import through a link that leaves a plugin's folder.
//
// The policy is the project's `.claude/settings.json`. Agents other than
// Claude Code don't enforce it, so this also checks what they edit and the
// commands it denies.
//
// Codex lets a call through when a hook fails any other way, so every failure
// here has to end in exit 2.

import { existsSync, readFileSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'

import { extensionsFrom, judge, protects, RULE } from './judge.ts'

type Call = { cwd: string; tool_input: { command?: unknown } }

const BASH_RULE = /^Bash\((.+?)(?::\*)?\)$/
const PATCH_TARGET = /^\*\*\* (?:Add File|Update File|Delete File|Move to): (.+)$/gm

/** The nearest project with settings, looking from `cwd` up to its git root. */
function findProject(cwd: string) {
  for (let dir = resolve(cwd); ; dir = dirname(dir)) {
    const settings = join(dir, '.claude', 'settings.json')
    if (existsSync(settings)) {
      return { root: dir, deny: JSON.parse(readFileSync(settings, 'utf8')).permissions?.deny }
    }
    if (existsSync(join(dir, '.git')) || dir === dirname(dir)) return undefined
  }
}

/** The denied command the shell text runs, from rules shaped like `Bash(make:*)`. */
function deniedCommand(command: string, deny: unknown): string | undefined {
  const denied = Array.isArray(deny) ? deny.flatMap(rule => BASH_RULE.exec(rule)?.[1] ?? []) : []
  const segments = command.split(/\$\(|[;&|\n()`]+/).map(segment => segment.trim())

  return denied.find(prefix => segments.some(s => s === prefix || s.startsWith(`${prefix} `)))
}

function check({ cwd, tool_input }: Call): string | undefined {
  const project = findProject(cwd)
  if (project === undefined) return undefined

  const { command } = tool_input
  if (typeof command !== 'string') throw new Error('the call carried no command')

  const policy = { extensions: extensionsFrom(project.deny), root: project.root }

  // A patch arrives as the apply_patch tool or as a heredoc to a shell.
  for (const [, target = ''] of command.matchAll(PATCH_TARGET)) {
    if (protects(target.trim(), policy)) return `the patch would edit ${target.trim()}. ${RULE}`
  }

  const denied = deniedCommand(command, project.deny)
  if (denied !== undefined) return `this project denies \`${denied}\`. ${RULE}`

  return judge(command, policy)
}

function refuse(reason: string): never {
  console.error(`source-guard: ${reason}`)
  process.exit(2)
}

try {
  const reason = check(JSON.parse(readFileSync(0, 'utf8')))
  if (reason !== undefined) refuse(reason)
} catch (error) {
  refuse(`the guard itself failed, so the call was not run (${error}). Tell the user.`)
}
