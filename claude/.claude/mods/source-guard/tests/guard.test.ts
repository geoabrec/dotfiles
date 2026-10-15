import { describe, expect, test } from 'claude-code/testing'

import { extensionsFrom, judge } from '../hooks/judge'

const ROOT = '/home/u/learncpp'
const SCRATCH = '/tmp/claude-1000/scratchpad'
const DENY = ['Edit(**/*.cpp)', 'Edit(**/*.h)', 'Edit(**/*.hpp)', 'Bash(make:*)']
const policy = { extensions: extensionsFrom(DENY), root: ROOT }

const BASELINE =
  'g++ -std=c++23 -g -pedantic-errors -Wall -Wextra -Wconversion -Wsign-conversion -Werror'

const REFUSED = [
  'echo "int main() {}" > hello.cpp',
  'cat >> chapter-01/quizzes/q1.cpp <<EOF\nint x;\nEOF',
  `printf x >${ROOT}/chapter-00/examples/hello.cpp`,
  'bash -c "echo x > util.h"',
  'g++ -fsyntax-only a.cpp 2> errors.hpp',
  "sed -i 's/a/b/' hello.cpp",
  "sed -ni.bak 's/a/b/p' chapter-00/examples/hello.cpp",
  'for f in *.cpp; do sed -i s/a/b/ "$f"; done',
  "perl -pi -e 's/a/b/' hello.cpp",
  'clang-format -i hello.cpp',
  "find . -name '*.h' | xargs clang-format -i",
  'echo x | tee hello.cpp',
  'dd if=/dev/zero of=hello.cpp',
  `cp ${SCRATCH}/solution.cpp chapter-01/quizzes/`,
  `mv ${SCRATCH}/solution.txt chapter-01/quizzes/q1.cpp`,
  'cp build/generated.txt main.cpp',
  'curl -o hello.cpp https://example.com/x',
  'wget https://example.com/solution.cpp',
  'git apply fix.patch',
  'patch -p1 < fix.patch',
  "nvim --headless -c '%s/a/b/' -c wq hello.cpp",
  `python3 -c "open('hello.cpp','w').write('x')"`,
  `${BASELINE} -o hello hello.cpp`,
  `${BASELINE} -o hello.cpp hello.cpp`,
  `${BASELINE} -obuild/x.cpp hello.cpp`,
  'mkdir -p build && clang++ hello.cpp -o ./a.out && ./a.out',
]

const ALLOWED = [
  `${BASELINE} -o build/hello chapter-00/examples/hello.cpp`,
  `${BASELINE} -fsyntax-only chapter-00/examples/hello.cpp 2>&1`,
  'gcc -std=c99 -o chapter-2/executables/pun chapter-2/programs/pun.c',
  `g++ -o ${SCRATCH}/demo ${SCRATCH}/demo.cpp && ${SCRATCH}/demo`,
  'g++ -fsyntax-only hello.cpp 2> build/errors.txt',
  'g++ hello.cpp -o /dev/null',
  `cat > ${SCRATCH}/demo.cpp <<'EOF'\nint main() { return 0; }\nEOF`,
  `clang-format -i ${SCRATCH}/demo.cpp`,
  'clang-format --dry-run chapter-00/examples/hello.cpp',
  "sed -i 's/a/b/' chapter-00/notes.md",
  'echo "## 1.1" >> chapter-01/notes.md',
  'git mv hello.cpp chapter-00/examples/',
  'mv chapter-00/hello.cpp chapter-00/examples/hello.cpp',
  'cat chapter-00/examples/hello.cpp',
  'grep -n "std::cout" chapter-00/examples/*.cpp',
  'git commit -m "Move hello.cpp -> examples/hello.cpp"',
  'git diff --stat && git log --oneline -5',
  "find . -name '*.cpp' -o -name '*.h'",
  'git apply --check fix.patch',
  './build/hello > build/out.txt',
]

describe('judge', () => {
  for (const command of REFUSED) {
    test(`refuses: ${command.slice(0, 60)}`, () => {
      expect(judge(command, policy)).toBeDefined()
    })
  }

  for (const command of ALLOWED) {
    test(`allows: ${command.slice(0, 60)}`, () => {
      expect(judge(command, policy)).toBeUndefined()
    })
  }

  test('a project with no Edit denies on source is left alone', () => {
    const open = { extensions: extensionsFrom(['Bash(make:*)']), root: ROOT }

    expect(judge('echo x > hello.cpp', open)).toBeUndefined()
  })

  test('reads the extensions from Edit rules only', () => {
    expect(extensionsFrom(DENY).sort()).toEqual(['cpp', 'h', 'hpp'])
    expect(extensionsFrom(undefined)).toEqual([])
  })
})

describe('the hook', () => {
  test('denies a write to source and lets a compile through', async ($, on) => {
    const ran: string[] = []
    on('settings.read', () => ({ value: { permissions: { deny: DENY } } }))
    on('session.root', () => ({ value: ROOT }))
    on('tool.call', { tool: 'Bash' }, (_, e) => {
      ran.push(e.command)

      return { result: { stdout: '', stderr: '' } }
    })

    const refused = await $.tool.call({ tool: 'Bash', command: 'echo x > hello.cpp' })
    expect(refused.deny).toContain('source-guard')

    const compile = `${BASELINE} -o build/hello hello.cpp`
    const allowed = await $.tool.call({ tool: 'Bash', command: compile })
    expect(allowed.deny).toBeUndefined()
    expect(ran).toEqual([compile])
  })
})
