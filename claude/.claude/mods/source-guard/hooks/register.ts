import type { Register } from 'claude-code'

import { extensionsFrom, judge } from './judge'

const FAILED =
  'source-guard: the guard itself failed, so the command was not run. ' +
  'Tell the user; /plugin can disable source-guard while it is fixed.'

export const register: Register = on => {
  // Bash and Monitor are the two built-in tools that run a shell command.
  on('tool.call', { tool: ['Bash', 'Monitor'] }, async ($, e, next) => {
    if (typeof e.command !== 'string') return next(e)

    // Read on every call: the project's own Edit denies are the one place
    // the protected extensions are written, and they may change mid-session.
    const { permissions } = await $.settings.read()
    const deny = (permissions as { deny?: unknown } | undefined)?.deny
    const extensions = extensionsFrom(deny)
    if (extensions.length === 0) return next(e)

    const reason = judge(e.command, { extensions, root: await $.session.root() })

    return reason === undefined ? next(e) : { deny: `${$.plugin.name}: ${reason}` }
  }).catch(($, e, next) => (next.called ? next(e) : { deny: FAILED }))
}
