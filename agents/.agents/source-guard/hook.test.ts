// Run with: node --no-warnings --test agents/.agents/source-guard/hook.test.ts
// judge.ts has its own tests in the Claude mod: `claude plugin test`.

import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'
import { after, test } from 'node:test'

const HOOK = join(import.meta.dirname, 'hook.ts')
const DENY = ['Edit(**/*.cpp)', 'Edit(**/*.h)', 'Bash(make:*)', 'Bash(git push --force:*)']
const ROOTS: string[] = []

after(() => ROOTS.forEach(root => rmSync(root, { recursive: true })))

function project(settings: string = JSON.stringify({ permissions: { deny: DENY } })) {
  const root = mkdtempSync(join(tmpdir(), 'source-guard-'))
  ROOTS.push(root)
  mkdirSync(join(root, '.claude'))
  mkdirSync(join(root, 'chapter-00'))
  writeFileSync(join(root, '.claude', 'settings.json'), settings)

  return root
}

function run(input: string) {
  return spawnSync(process.execPath, ['--no-warnings', HOOK], { input, encoding: 'utf8' })
}

const call = (cwd: string, command: unknown) => run(JSON.stringify({ cwd, tool_input: { command } }))

const patch = (target: string) => `*** Begin Patch\n*** Update File: ${target}\n@@\n-a\n+b\n*** End Patch`

const REFUSED = [
  'echo x > hello.cpp',
  'g++ -o hello hello.cpp',
  patch('chapter-00/hello.cpp'),
  '*** Begin Patch\n*** Add File: util.h\n+x\n*** End Patch',
  '*** Begin Patch\n*** Delete File: hello.cpp\n*** End Patch',
  '*** Begin Patch\n*** Update File: notes.md\n*** Move to: notes.cpp\n*** End Patch',
  `apply_patch <<'EOF'\n${patch('hello.cpp')}\nEOF`,
  'make',
  'cd build && make test',
  'git push --force origin main',
]

const ALLOWED = [
  'g++ -std=c++23 -o build/hello hello.cpp',
  'cat chapter-00/hello.cpp',
  'git status --short',
  'makepkg --version',
  patch('chapter-00/notes.md'),
]

for (const command of REFUSED) {
  test(`refuses: ${command.slice(0, 50)}`, () => {
    const { status, stderr } = call(project(), command)

    assert.equal(status, 2)
    assert.match(stderr, /^source-guard: /)
  })
}

for (const command of ALLOWED) {
  test(`allows: ${command.slice(0, 50)}`, () => {
    const { status, stderr } = call(project(), command)

    assert.equal(status, 0, stderr)
  })
}

test('finds the policy from a folder inside the project', () => {
  assert.equal(call(join(project(), 'chapter-00'), 'echo x > hello.cpp').status, 2)
})

test('an absolute path outside the project is not protected', () => {
  assert.equal(call(project(), patch('/tmp/scratch/demo.cpp')).status, 0)
})

test('a project that denies nothing is left alone', () => {
  assert.equal(call(project('{}'), 'echo x > hello.cpp').status, 0)
})

test('stops looking at the git root', () => {
  const nested = join(project(), 'repo')
  mkdirSync(join(nested, '.git'), { recursive: true })

  assert.equal(call(nested, 'echo x > hello.cpp').status, 0)
})

test('refuses when it cannot read the call or the policy', () => {
  assert.equal(run('not json').status, 2)
  assert.equal(call(project('not json'), 'ls').status, 2)
  assert.equal(call(project(), ['bash', '-c', 'ls']).status, 2)
})
