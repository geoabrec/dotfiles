// The guard's judgment, kept free of the engine so it can be tested as a
// plain function: a shell command and a policy in, a reason to refuse out.
//
// It reads the command as text. A shell can always hide a write behind a
// variable or a script file, so this is a tight net, not a proof.

export type Policy = {
  /** Lowercase extensions without the dot: `cpp`, `h`. */
  extensions: readonly string[]
  /** The project's root, absolute. Files outside it are not protected. */
  root: string
}

/** Folders a compiler may write into, as the projects' CLAUDE.md files name them. */
const OUTPUT_DIRS = ['build', 'executables']

const EDIT_RULE = /^(?:Edit|Write|MultiEdit|NotebookEdit)\((?:.*\/)?\*\.([A-Za-z0-9+_-]+)\)$/

const COMPILERS = /^(?:g\+\+|c\+\+|clang\+\+|gcc|cc|clang)(?:-\d+)?$/
const EDITORS = new Set(['nvim', 'vim', 'vi', 'ed', 'ex', 'nano', 'emacs'])
const INLINE_CODE = new Set(['python', 'python3', 'perl', 'ruby', 'node', 'lua', 'php'])
const COPIERS = new Set(['cp', 'mv', 'install', 'ln'])
const READ_ONLY_PATCH = /^--(?:check|stat|numstat|summary|dry-run)$/

/**
 * The extensions a project's settings deny editing, read from rules shaped
 * like `Edit(**\/*.cpp)`. None means the project asked for no protection.
 */
export function extensionsFrom(deny: unknown): string[] {
  if (!Array.isArray(deny)) return []

  const found = new Set<string>()
  for (const rule of deny) {
    const ext = typeof rule === 'string' ? EDIT_RULE.exec(rule)?.[1] : undefined
    if (ext !== undefined) found.add(ext.toLowerCase())
  }

  return [...found]
}

const unquote = (word: string) => word.replace(/^["']+|["']+$/g, '')

const escape = (text: string) => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

function normalize(path: string): string {
  const out: string[] = []
  for (const part of path.split('/')) {
    if (part === '' || part === '.') continue
    if (part === '..') out.pop()
    else out.push(part)
  }

  return '/' + out.join('/')
}

/**
 * Returns a sentence saying why the command must not run, or undefined when
 * the guard has no objection.
 */
export function judge(command: string, policy: Policy): string | undefined {
  if (policy.extensions.length === 0) return undefined

  // Longest first, so `.hpp` is not read as `.h` followed by `pp`.
  const exts = [...policy.extensions].sort((a, b) => b.length - a.length).map(escape).join('|')
  const isSourceName = new RegExp(`\\.(?:${exts})$`, 'i')
  const sourceMention = new RegExp(`[\\w~$@%+{}*?\\[\\]/.-]*\\.(?:${exts})(?![\\w])`, 'gi')
  const root = normalize(policy.root)

  // An absolute path outside the project (a scratch file) is nobody's
  // source. Anything else (relative, `~`, `$VAR`, a glob) is assumed to be.
  const isOutside = (path: string) =>
    path.startsWith('/') && !path.startsWith('//') && !(normalize(path) + '/').startsWith(root + '/')
  const isSource = (word: string) => {
    const path = unquote(word)

    return isSourceName.test(path) && !isOutside(path)
  }
  // Every source file name the command spells, and those inside the project.
  const named = command.match(sourceMention) ?? []
  const touched = named.filter(isSource)

  const rule =
    'This project protects its source files: the user writes their own code. ' +
    'Do not route around this; explain or give a hint instead.'

  // 1. Redirects, wherever they sit (a nested `sh -c "..."` included).
  const redirect = /(?<![-=<>])(?:&|\d)?>{1,2}\|?[ \t]*("[^"]*"|'[^']*'|[^\s;&|<>()]+)/g
  for (const [, target = ''] of command.matchAll(redirect)) {
    if (isSource(target)) return `the redirect would write ${unquote(target)}. ${rule}`
  }

  // 2. Commands that write files, one simple command at a time.
  for (const segment of command.split(/\$\(|[;&|\n()`]+/)) {
    const words = segment.trim().split(/\s+/).filter(Boolean).map(unquote)

    for (const [at, word] of words.entries()) {
      const verb = word.slice(word.lastIndexOf('/') + 1)
      const args = words.slice(at + 1)
      const flags = args.filter(arg => arg.startsWith('-'))
      const files = args.filter(arg => !arg.startsWith('-'))

      const isInPlaceSed = verb === 'sed' && flags.some(f => /^-[a-zA-Z]*i/.test(f) || f.startsWith('--in-place'))
      const isInPlacePerl = verb === 'perl' && flags.some(f => /^-[a-zA-Z]*i/.test(f))
      if ((isInPlaceSed || isInPlacePerl) && touched.length > 0) {
        return `${verb} would edit ${touched[0]} in place. ${rule}`
      }

      const isFormatting = verb === 'clang-format' && flags.some(f => /^--?i$/.test(f))
      if (isFormatting && (files.length === 0 || !files.every(isOutside))) {
        return `clang-format -i rewrites source files. Use --dry-run to check formatting. ${rule}`
      }

      if (verb === 'tee' || verb === 'truncate') {
        const hit = files.find(isSource)
        if (hit !== undefined) return `${verb} would overwrite ${hit}. ${rule}`
      }

      if (verb === 'dd') {
        const hit = args.find(arg => arg.startsWith('of=') && isSource(arg.slice(3)))
        if (hit !== undefined) return `dd would overwrite ${hit.slice(3)}. ${rule}`
      }

      // Moving the user's own source around inside the project is fine;
      // bringing anything else in under a source file's name is not.
      if (COPIERS.has(verb) && files.length >= 2) {
        const target = files.at(-1) ?? ''
        const sources = files.slice(0, -1)
        const makesSource = isSourceName.test(target) || sources.some(s => isSourceName.test(s))
        if (makesSource && !isOutside(target) && !sources.every(isSource)) {
          return `${verb} would bring a file in as project source (${target}). ${rule}`
        }
      }

      if ((verb === 'curl' || verb === 'wget') && named.length > 0) {
        return `${verb} would download a source file. ${rule}`
      }

      const isPatching =
        verb === 'patch' || (verb === 'git' && (args[0] === 'apply' || args[0] === 'am'))
      if (isPatching && !flags.some(f => READ_ONLY_PATCH.test(f))) {
        return `a patch can rewrite source files and the guard cannot see inside it. ${rule}`
      }

      if (EDITORS.has(verb)) {
        const hit = files.find(isSource)
        if (hit !== undefined) return `${verb} would open ${hit} for editing. ${rule}`
      }

      const hasInlineCode = INLINE_CODE.has(verb) && flags.some(f => /^-[a-zA-Z]*[ce]$/.test(f))
      if (hasInlineCode && touched.length > 0) {
        return `inline ${verb} code names ${touched[0]}; read it with the Read tool instead. ${rule}`
      }

      if (COMPILERS.test(verb)) {
        const flagAt = args.findIndex(arg => arg === '-o' || (arg.startsWith('-o') && arg.length > 2))
        const flag = args[flagAt]
        const output = flag === '-o' ? args[flagAt + 1] : flag?.slice(2)

        if (output !== undefined) {
          const isBuildPath = output.split('/').some(part => OUTPUT_DIRS.includes(part))
          const isAllowed =
            output === '/dev/null' || isOutside(output) || (isBuildPath && !isSourceName.test(output))
          if (!isAllowed) {
            return (
              `the compiler output "${output}" would land outside the build folder. ` +
              `Send it to ${OUTPUT_DIRS.map(d => `${d}/<name>`).join(' or ')}, or use -fsyntax-only.`
            )
          }
        }
      }
    }
  }

  return undefined
}
