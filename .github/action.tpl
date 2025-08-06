{{- define "escape_chars" }}{{ . | strings.ReplaceAll "_" "\\_" | strings.ReplaceAll "|" "\\|" | strings.ReplaceAll "*" "\\*" }}{{- end }}

{{- define "escape_spaces" }}{{ . | strings.ReplaceAll " " "_" }}{{- end }}

{{- define "sanitize_string" }}{{ . | strings.ReplaceAll "\n\n" "<br><br>" | strings.ReplaceAll " \n" "<br>" | strings.ReplaceAll "\n" "<br>" | tmpl.Exec "escape_chars" }}{{- end }}

{{- define "sanitize_url" }}{{ . | strings.ReplaceAll "_" "__" | strings.ReplaceAll "\n" " " | strings.ReplaceAll "<br>" " " | strings.ReplaceAll " " " " | strings.ReplaceAll "-" "--" | tmpl.Exec "escape_spaces" }}{{- end }}

{{- define "sanitize_boolean" }}{{ . | strings.ReplaceAll "true" "yes" | strings.ReplaceAll "false" "no" | tmpl.Exec "sanitize_url" }}{{- end }}

{{- define "boolean_color" }}{{ . | strings.ReplaceAll "true" "important" | strings.ReplaceAll "false" "inactive" | tmpl.Exec "sanitize_url" }}{{- end }}

{{- $action := (datasource "action") -}}

## Inputs

{{- range $key, $input := $action.inputs }}

### {{ tmpl.Exec "escape_chars" $key }}

![Required](https://img.shields.io/badge/Required-{{ if (has $input "required") }}{{ tmpl.Exec "sanitize_boolean" $input.required }}{{ else }}no{{ end }}-{{ if (has $input "required") }}{{ tmpl.Exec "boolean_color" $input.required }}{{ else }}inactive{{ end }}?style=flat-square)
{{ if (has $input "default") }}![Default](https://img.shields.io/badge/Default-{{ tmpl.Exec "sanitize_url" $input.default }}-blue?style=flat-square){{ else }}![Default](https://img.shields.io/badge/Default-none-lightgrey?style=flat-square){{ end }}

{{ tmpl.Exec "sanitize_string" $input.description }}

{{- end }}

## Outputs

{{- range $key, $output := $action.outputs }}

### {{ tmpl.Exec "escape_chars" $key }}

![Output](https://img.shields.io/badge/Output-{{ tmpl.Exec "sanitize_url" $key }}-green?style=flat-square)

{{ tmpl.Exec "sanitize_string" $output.description }}

{{- end }}

## Usage

```yaml
- name: {{ $action.name }}
  uses: {{ "${{ github.repository }}" }}@{{ "${{ github.ref }}" }}
  with:
{{- range $key, $input := $action.inputs }}
    {{ $key }}: {{ if (has $input "default") }}{{ $input.default }}{{ else }}'your-value-here'{{ end }}
{{- end }}
```

## Example Workflow

```yaml
name: Auto-Merge Enhanced Processing

on:
  pull_request:
    types: [auto_merge_enabled]

jobs:
  process-auto-merge:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: read
      issues: read
      checks: read
      id-token: write
    steps:
      - name: {{ $action.name }}
        uses: {{ "${{ github.repository }}" }}@v1
        with:
          github-token: {{ "${{ secrets.GITHUB_TOKEN }}" }}
          # Choose ONE authentication method:
          anthropic-api-key: {{ "${{ secrets.ANTHROPIC_API_KEY }}" }}
          # claude-code-oauth-token: {{ "${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}" }}
          enable-claude-generation: true
          check-timeout-seconds: 900
```