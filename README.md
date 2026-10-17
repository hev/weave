# Weave

**Explicit agent context, composed for an assignment.** A standalone Go CLI with a local browser reviewer. Extract maintained instructions, choose task sources in an editable JSON recipe, build a reproducible bundle, and inspect every byte and its provenance.

No service, account, model, API key, JavaScript runtime, or private dependency is required. This is a prototype, not a harness injection recorder or scheduler. Apache-2.0.

## Install

Requires Go 1.23 or newer:

```sh
go install github.com/hev/weave/cmd/weave@latest
# Or from a checkout:
go build -o weave ./cmd/weave
```

## Try the synthetic project

From a fresh checkout, `sh examples/quickstart.sh` executes the complete CLI flow in temporary directories and checks deterministic output. For an inspectable session:

```sh
go build -o weave ./cmd/weave
mkdir -p demo
./weave assess --root examples/project --out demo/assessment
./weave extract --root examples/project --out demo/extracted
# Edit demo/extracted/improved.recipe.json: set task and choose applicable sources.
# Two ready-to-use task recipes demonstrate selection:
./weave build --root demo/extracted/sources --recipe examples/review.recipe.json --out demo/review
./weave build --root demo/extracted/sources --recipe examples/test.recipe.json --out demo/test
./weave diff --before demo/review --after demo/test --out demo/comparison
./weave review --bundle demo/comparison
```

Open the printed loopback URL manually; stop with Ctrl-C. Or open any generated `index.html` directly, even offline. The reviewer offers complete assembled Markdown, ordered sources with byte counts/hashes, complete file contents, evidence-linked assessment findings, a proposed recipe, and a before/after file comparison. Toggle light/dark mode; the layout adapts to phones. Source HTML and Markdown are displayed as text, never rendered as HTML.

`review --addr 127.0.0.1:8765` chooses a fixed port. Non-loopback bind addresses are refused. No browser launches automatically. Static exports contain the full source contents: share them only where those contents belong.

## Recipes and outputs

Recipes are ordinary JSON, with no hidden defaults or templating:

```json
{
  "version": 1,
  "task": "Review the storage change",
  "sources": [
    {"path": "AGENTS.md", "target": "AGENTS.md"},
    {"path": ".claude/agents/reviewer.md", "target": ".claude/agents/reviewer.md"}
  ]
}
```

Paths are relative to `--root`; targets are relative to `materialized/`. Ordering is explicit and contributes to the digest. Include each skill asset with its original relative target, as in `examples/test.recipe.json`. Recipes may select Codex `.agents/skills/` sources as well as Claude `.claude/skills/`. Materialization preserves source bytes and directory relationships. It does not install into your project or claim the harness automatically loads every selected file. The assignment appears in `context.md`; pass that complete context explicitly to your chosen harness, alongside any selected materialized native files.

- `assess`: discovers `AGENTS.md`/`CLAUDE.md` at any depth and root `.claude/agents/`, `.claude/skills/`, `.agents/skills/`. Writes findings, the baseline recipe, and an editable improved recipe.
- `extract`: also copies those sources into a standalone `sources/` tree. Build using that directory as `--root` to decouple the bundle from the original project.
- `build`: writes `bundle.json`, `context.md`, `materialized/`, and the self-contained `index.html`. All Markdown files are assembled in recipe order; binary/other assets remain available unchanged in materialized output and base64 in the manifest.
- `diff`: validates bundle digests, then writes `diff.json` and a complete before/after reviewer. Changes include assignment, added/removed/modified files, and changed source paths. This prototype compares whole files side by side rather than computing a line-level patch.
- `review`: serves only the generated HTML on loopback. The static artifact works without this server.

Every output directory must be new; sources and existing outputs are never overwritten. Parent directories must exist. Sources must be regular files, at most 16 MiB each. Absolute paths, traversal, backslashes, symlink sources (including ancestor symlinks), duplicate targets and file/directory target collisions are refused. Output files are staged before a new destination is exclusively claimed; an interrupted final move may leave an incomplete new output directory, which must be inspected and removed explicitly before retry.

## Honest assessment

The synthetic fixture intentionally includes opposite `Always run tests.` / `Never run tests.` directives, a repeated instruction, a missing link and hostile HTML. Findings include source path and line. Checks are deterministic lexical heuristics: exact duplicate top-level instruction files, repeated long lines, files over 8,000 bytes, absence of an explicit `Scope:` marker, missing local Markdown links, and matching opposite directive phrases. Nested/local guidance is inspected alongside root guidance; the tool cannot decide which should win.

The improved recipe omits exact duplicate instruction files and retains all other sources for your review. It is a concrete editable starting point, not an automatic semantic rewrite. Diagnostics and proposed recipes never modify source files. Referenced files are checked but not silently included; add required context explicitly. Heuristics may miss paraphrased conflicts or flag intentional repetition. Discovery does not read global home-directory guidance, ignored harness state, remote links or hidden injected context. A bundle digest is a reproducibility handle, not proof of what a harness consumed. External capture tools can use the digest and source manifest without duplicating capture here.

## Development

```sh
go vet ./...
go test -race ./...
sh examples/quickstart.sh
```

CI runs the same checks on Linux. All checked-in examples are synthetic. No package registry release, shared runtime activation, or scheduler integration is part of this prototype.
