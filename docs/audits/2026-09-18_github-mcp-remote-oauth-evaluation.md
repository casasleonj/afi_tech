# GitHub MCP Remote OAuth Evaluation

**Status:** `FAILED_AS_EXPECTED`; no credentials were acquired and no gateway reload
occurred.

## Attempt

The host operator ran:

```bash
hermes mcp add github \
  --url https://api.githubcopilot.com/mcp \
  --auth oauth \
  --connect-timeout 60
```

Hermes reported OAuth setup followed by a connection failure:

```text
Registration failed: 404 404 page not found
```

The operator then explicitly accepted saving the entry. Hermes saved it
**disabled**; it has not been loaded by the gateway.

## Root cause

GitHub's official hosted MCP endpoint is `https://api.githubcopilot.com/mcp/`.
It rejects generic dynamic OAuth client registration. Hermes' official MCP guide
explicitly documents this constraint: GitHub is intentionally absent from its
catalog because the hosted service requires each client host to provide a
GitHub OAuth App; generic dynamic registration is rejected.

The missing trailing slash was corrected in the analysis, but it does not fix
the registration rejection. Repeating `hermes mcp login github` before
supplying a pre-registered client would repeat the same unsupported flow.

## Immediate safe recovery

Remove the disabled, unusable entry on the **real host**:

```bash
hermes mcp remove github
```

Then verify:

```bash
hermes mcp list
```

This changes only the failed host MCP configuration. It does not touch the
Telegram gateway, Docker terminal sandbox, `.env`, Git history or repository
credentials.

## Revised candidate

The preferred next evaluation is GitHub's official **local stdio** MCP server,
a child of the host Hermes process authenticated as a GitHub App installation.
It can mint and refresh short-lived installation tokens. The official project
states this GitHub App mode is unavailable for the hosted HTTP endpoint.

This candidate is not installed yet. It requires a deliberate GitHub App,
installation scoped only to `casasleonj/afi_tech`, a protected host private-key
file, and a host-Docker prerequisite check. The key must be mounted read-only
only into the official MCP child; it must never be forwarded into Hermes'
terminal Docker sandbox.

## Evidence sources

- Hermes MCP guide: GitHub hosted MCP rejects generic dynamic registration.
- GitHub official `github/github-mcp-server` documentation: hosted URL, toolset
  filtering, and local GitHub App authentication behavior.
- Host terminal output supplied by the operator; no secret values are recorded.
