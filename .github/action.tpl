{{- define "escape_chars" }}{{ . | strings.ReplaceAll "_" "\\_" | strings.ReplaceAll "|" "\\|" | strings.ReplaceAll "*" "\\*" }}{{- end }}

{{- define "escape_spaces" }}{{ . | strings.ReplaceAll " " "_" }}{{- end }}

{{- define "sanitize_string" }}{{ . | strings.ReplaceAll "\n\n" "<br><br>" | strings.ReplaceAll " \n" "<br>" | strings.ReplaceAll "\n" "<br>" | tmpl.Exec "escape_chars" }}{{- end }}

{{- define "sanitize_url" }}{{ . | strings.ReplaceAll "_" "__" | strings.ReplaceAll "\n" " " | strings.ReplaceAll "<br>" " " | strings.ReplaceAll " " " " | strings.ReplaceAll "-" "--" | tmpl.Exec "escape_spaces" }}{{- end }}

{{- define "sanitize_boolean" }}{{ . | strings.ReplaceAll "true" "yes" | strings.ReplaceAll "false" "no" | tmpl.Exec "sanitize_url" }}{{- end }}

{{- define "boolean_color" }}{{ . | strings.ReplaceAll "true" "important" | strings.ReplaceAll "false" "inactive" | tmpl.Exec "sanitize_url" }}{{- end }}

{{- $action := (datasource "action") -}}

## Usage

```yaml
- name: {{ $action.name }}
  uses: {{ "${{ github.repository }}" }}@{{ "${{ github.ref }}" }}
  with:
{{- range $key, $input := $action.inputs }}
    {{- if (has $input "description") }}
    # {{ $input.description }}
    {{- end }}
    {{ $key }}: {{ if (has $input "default") }}{{ $input.default }}{{ else }}'your-value-here'{{ end }}
{{- end }}
```

## Example Workflow

```yaml
{{ file.Read ".github/workflows/automerge.yml" }}
```

## Inputs

{{- range $key, $input := $action.inputs }}

### {{ $key }}

![Required](https://img.shields.io/badge/Required-{{ if (has $input "required") }}{{ tmpl.Exec "sanitize_boolean" $input.required }}{{ else }}no{{ end }}-{{ if (has $input "required") }}{{ tmpl.Exec "boolean_color" $input.required }}{{ else }}inactive{{ end }}?style=flat-square)
{{ if (has $input "default") }}![Default](https://img.shields.io/badge/Default-{{ tmpl.Exec "sanitize_url" $input.default }}-blue?style=flat-square){{ else }}![Default](https://img.shields.io/badge/Default-none-lightgrey?style=flat-square){{ end }}

{{ tmpl.Exec "sanitize_string" $input.description }}

{{- end }}

## Outputs

{{- range $key, $output := $action.outputs }}

### {{ $key }}

![Output](https://img.shields.io/badge/Output-{{ tmpl.Exec "sanitize_url" $key }}-green?style=flat-square)

{{ tmpl.Exec "sanitize_string" $output.description }}

{{- end }}

